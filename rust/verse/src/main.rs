use anyhow::Result;
use crossterm::{
    event::{self, Event, KeyCode, KeyEventKind},
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use rand::Rng;
use ratatui::{
    backend::{Backend, CrosstermBackend},
    prelude::*,
    widgets::Widget,
};
use regex::Regex;
use scraper::{Html, Selector};
use std::{env, io};
use tui_widget_list::{widget::List, ListState, ListableWidget, ScrollAxis};

#[derive(Debug, Clone)]
pub struct ListItem<'a> {
    title: &'a str,
    url: &'a str,
    max_chapter: usize,
    chapter: String,
    prefix: Option<&'a str>,
}

impl<'a> ListItem<'a> {
    pub fn new(title: &'a str, url: &'a str, max_chapter: usize) -> Self {
        Self {
            title: title,
            url: url,
            max_chapter: max_chapter,
            chapter: String::new(),
            prefix: None,
        }
    }

    pub fn prefix(mut self, prefix: Option<&'a str>) -> Self {
        self.prefix = prefix;
        self
    }

    fn get_line(self) -> String {
        let chapter = format!("({:0>3}/{:0>3})", self.chapter, self.max_chapter);
        let text = if let Some(prefix) = self.prefix {
            combine_text(self.title, prefix, chapter)
        } else {
            combine_text(self.title, "  ", chapter)
        };
        text
    }
}

impl ListableWidget for ListItem<'_> {
    fn size(&self, _: &ScrollAxis) -> usize {
        1
    }

    fn highlight(self) -> Self {
        self.prefix(Some("> "))
    }
}

impl Widget for ListItem<'_> {
    fn render(self, area: Rect, buf: &mut Buffer) {
        self.get_line().render(area, buf);
    }
}

fn init_terminal() -> Result<Terminal<CrosstermBackend<io::Stdout>>> {
    crossterm::execute!(io::stdout(), EnterAlternateScreen)?;
    enable_raw_mode()?;

    let backend = CrosstermBackend::new(io::stdout());

    let mut terminal = Terminal::new(backend)?;
    terminal.hide_cursor()?;

    panic_hook();

    Ok(terminal)
}

fn reset_terminal() -> Result<()> {
    disable_raw_mode()?;
    crossterm::execute!(io::stdout(), LeaveAlternateScreen)?;

    Ok(())
}

fn panic_hook() {
    let original_hook = std::panic::take_hook();

    std::panic::set_hook(Box::new(move |panic| {
        reset_terminal().unwrap();
        original_hook(panic);
    }));
}

pub struct App<'a> {
    list: List<'a, ListItem<'a>>,
    state: ListState,
}

impl<'a> App<'a> {
    pub fn new(testament: Vec<ListItem<'a>>) -> App<'a> {
        let mut state = ListState::default();
        state.select(Some(0));
        App {
            list: testament.into(),
            state,
        }
    }
}

pub fn run_app<'a, B: Backend>(
    terminal: &mut Terminal<B>,
    mut app: App<'a>,
) -> Result<(&'a str, &'a str, String, usize)> {
    loop {
        terminal.draw(|f| ui(f, &mut app))?;

        if let Event::Key(key) = event::read()? {
            if key.kind == KeyEventKind::Press {
                match key.code {
                    KeyCode::Char('q') => return Ok(("", "", String::new(), 0)),
                    KeyCode::Char('k') | KeyCode::Up => app.state.previous(),
                    KeyCode::Char('j') | KeyCode::Down => app.state.next(),
                    KeyCode::Esc => {
                        if let Some(i) = app.state.selected {
                            app.list.items[i].chapter.clear();
                        }
                    }
                    KeyCode::Enter => {
                        if let Some(i) = app.state.selected {
                            let chapter_number = app.list.items[i]
                                .chapter
                                .parse::<usize>()
                                .unwrap_or_default();
                            if 0 < chapter_number && chapter_number <= app.list.items[i].max_chapter
                            {
                                let title = app.list.items[i].title;
                                let url = app.list.items[i].url;
                                let chapter = chapter_number.to_string();
                                let max_chapter = app.list.items[i].max_chapter;
                                return Ok((title, url, chapter, max_chapter));
                            } else {
                                app.list.items[i].chapter.clear();
                            }
                        }
                    }
                    KeyCode::Char(ch) if ch.is_ascii_digit() => {
                        if let Some(i) = app.state.selected {
                            let len = app.list.items[i].chapter.len();
                            if len == 3 {
                                app.list.items[i].chapter = ch.to_string();
                            } else {
                                app.list.items[i].chapter.push(ch);
                            }
                        }
                    }
                    _ => {}
                }
            }
        }
    }
}

pub fn ui(f: &mut Frame, app: &mut App) {
    let list = app.list.clone();
    f.render_stateful_widget(list, f.size(), &mut app.state);
}

fn combine_text<'a>(title: &'a str, prefix: &'a str, chapter: String) -> String {
    let mut result = String::new();
    result += prefix;
    result += title;
    result += &chapter;
    result
}

fn get_verse(url: &str, id: &String) -> String {
    let resp = reqwest::blocking::get(url).unwrap_or_else(|_| panic!("failed to get {}", url));

    if !resp.status().is_success() {
        panic!("status code is not success: {}", resp.status())
    }

    let text = resp
        .text()
        .expect("failed to convert text (shoud be utf-8 encoding)");

    let fragment = Html::parse_fragment(text.as_str());
    let div_selector = Selector::parse("div").unwrap();
    let element = fragment
        .select(&div_selector)
        .find(|element| element.value().attr("id") == Some(id.as_str()))
        .unwrap_or_else(|| panic!("div#{} not found", id));

    let re = Regex::new(r"^(?<first>\d{1,3}):(?<second>\d{1,3})").unwrap();

    let result = element
        .text()
        .map(|s| re.replace_all(s, "[$first:$second] ").to_string())
        .collect::<Vec<String>>()
        .join("")
        .replace("\n[", "[");

    return result;
}

#[derive(Debug)]
struct Setting {
    old_testament: bool,
    new_testament: bool,
    random: bool,
}

fn init_setting() -> Setting {
    let mut setting = Setting {
        old_testament: false,
        new_testament: false,
        random: false,
    };

    let mut iter = env::args().skip(1);

    while let Some(arg) = iter.next() {
        match arg.as_str() {
            "-o" => setting.old_testament = true,
            "-n" => setting.new_testament = true,
            "-r" => setting.random = true,
            _ => {
                eprintln!("error: Unrecongnized option: '{}'", arg);
                std::process::exit(1);
            }
        }
    }
    setting
}

fn get_old_testament<'a>() -> Vec<ListItem<'a>> {
    vec![
        ListItem::new(
            "創世記",
            "http://bible.salterrae.net/kougo/html/genesis.html",
            50,
        ),
        ListItem::new(
            "出エジプト記",
            "http://bible.salterrae.net/kougo/html/exodus.html",
            40,
        ),
        ListItem::new(
            "レビ記",
            "http://bible.salterrae.net/kougo/html/leviticus.html",
            27,
        ),
        ListItem::new(
            "民数記",
            "http://bible.salterrae.net/kougo/html/numbers.html",
            36,
        ),
        ListItem::new(
            "申命記",
            "http://bible.salterrae.net/kougo/html/deuteronomy.html",
            34,
        ),
        ListItem::new(
            "ヨシュア記",
            "http://bible.salterrae.net/kougo/html/joshua.html",
            24,
        ),
        ListItem::new(
            "士師記",
            "http://bible.salterrae.net/kougo/html/judges.html",
            21,
        ),
        ListItem::new(
            "ルツ記",
            "http://bible.salterrae.net/kougo/html/ruth.html",
            4,
        ),
        ListItem::new(
            "サムエル記 上",
            "http://bible.salterrae.net/kougo/html/1samuel.html",
            31,
        ),
        ListItem::new(
            "サムエル記 下",
            "http://bible.salterrae.net/kougo/html/2samuel.html",
            24,
        ),
        ListItem::new(
            "列王紀 上",
            "http://bible.salterrae.net/kougo/html/1kings.html",
            22,
        ),
        ListItem::new(
            "列王紀 下",
            "http://bible.salterrae.net/kougo/html/2kings.html",
            25,
        ),
        ListItem::new(
            "歴代志 上",
            "http://bible.salterrae.net/kougo/html/1chronicles.html",
            29,
        ),
        ListItem::new(
            "歴代志 下",
            "http://bible.salterrae.net/kougo/html/2chronicles.html",
            36,
        ),
        ListItem::new(
            "エズラ記",
            "http://bible.salterrae.net/kougo/html/ezra.html",
            10,
        ),
        ListItem::new(
            "ネヘミヤ書",
            "http://bible.salterrae.net/kougo/html/nehemiah.html",
            13,
        ),
        ListItem::new(
            "エステル記",
            "http://bible.salterrae.net/kougo/html/esther.html",
            10,
        ),
        ListItem::new(
            "ヨブ記",
            "http://bible.salterrae.net/kougo/html/job.html",
            42,
        ),
        ListItem::new(
            "詩篇",
            "http://bible.salterrae.net/kougo/html/psalms.html",
            150,
        ),
        ListItem::new(
            "箴言",
            "http://bible.salterrae.net/kougo/html/proverbs.html",
            31,
        ),
        ListItem::new(
            "伝道の書",
            "http://bible.salterrae.net/kougo/html/ecclesiastes.html",
            12,
        ),
        ListItem::new(
            "雅歌",
            "http://bible.salterrae.net/kougo/html/songofsongs.html",
            8,
        ),
        ListItem::new(
            "イザヤ書",
            "http://bible.salterrae.net/kougo/html/isaiah.html",
            66,
        ),
        ListItem::new(
            "エレミヤ書",
            "http://bible.salterrae.net/kougo/html/jeremiah.html",
            52,
        ),
        ListItem::new(
            "哀歌",
            "http://bible.salterrae.net/kougo/html/lamentations.html",
            5,
        ),
        ListItem::new(
            "エゼキエル書",
            "http://bible.salterrae.net/kougo/html/ezekiel.html",
            48,
        ),
        ListItem::new(
            "ダニエル書",
            "http://bible.salterrae.net/kougo/html/daniel.html",
            12,
        ),
        ListItem::new(
            "ホセア書",
            "http://bible.salterrae.net/kougo/html/hosea.html",
            14,
        ),
        ListItem::new(
            "ヨエル書",
            "http://bible.salterrae.net/kougo/html/joel.html",
            3,
        ),
        ListItem::new(
            "アモス書",
            "http://bible.salterrae.net/kougo/html/amos.html",
            9,
        ),
        ListItem::new(
            "オバデヤ書",
            "http://bible.salterrae.net/kougo/html/obadiah.html",
            1,
        ),
        ListItem::new(
            "ヨナ書",
            "http://bible.salterrae.net/kougo/html/jonah.html",
            4,
        ),
        ListItem::new(
            "ミカ書",
            "http://bible.salterrae.net/kougo/html/micah.html",
            7,
        ),
        ListItem::new(
            "ナホム書",
            "http://bible.salterrae.net/kougo/html/nahum.html",
            3,
        ),
        ListItem::new(
            "ハバクク書",
            "http://bible.salterrae.net/kougo/html/habakkuk.html",
            3,
        ),
        ListItem::new(
            "ゼパニヤ書",
            "http://bible.salterrae.net/kougo/html/zephaniah.html",
            3,
        ),
        ListItem::new(
            "ハガイ書",
            "http://bible.salterrae.net/kougo/html/haggai.html",
            2,
        ),
        ListItem::new(
            "ゼカリヤ書",
            "http://bible.salterrae.net/kougo/html/zecariah.html",
            14,
        ),
        ListItem::new(
            "マラキ書",
            "http://bible.salterrae.net/kougo/html/malachi.html",
            4,
        ),
    ]
}
fn get_new_testament<'a>() -> Vec<ListItem<'a>> {
    vec![
        ListItem::new(
            "マタイによる福音書",
            "http://bible.salterrae.net/kougo/html/matthew.html",
            28,
        ),
        ListItem::new(
            "マルコによる福音書",
            "http://bible.salterrae.net/kougo/html/mark.html",
            16,
        ),
        ListItem::new(
            "ルカによる福音書",
            "http://bible.salterrae.net/kougo/html/luke.html",
            24,
        ),
        ListItem::new(
            "ヨハネによる福音書",
            "http://bible.salterrae.net/kougo/html/john.html",
            21,
        ),
        ListItem::new(
            "使徒行伝",
            "http://bible.salterrae.net/kougo/html/acts.html",
            28,
        ),
        ListItem::new(
            "ローマ人への手紙",
            "http://bible.salterrae.net/kougo/html/romans.html",
            16,
        ),
        ListItem::new(
            "コリント人への第一の手紙",
            "http://bible.salterrae.net/kougo/html/1corintians.html",
            16,
        ),
        ListItem::new(
            "コリント人への第二の手紙",
            "http://bible.salterrae.net/kougo/html/2corintians.html",
            13,
        ),
        ListItem::new(
            "ガラテヤ人への手紙",
            "http://bible.salterrae.net/kougo/html/galatians.html",
            6,
        ),
        ListItem::new(
            "エペソ人への手紙",
            "http://bible.salterrae.net/kougo/html/ephesians.html",
            6,
        ),
        ListItem::new(
            "ピリピ人への手紙",
            "http://bible.salterrae.net/kougo/html/philippians.html",
            4,
        ),
        ListItem::new(
            "コロサイ人への手紙",
            "http://bible.salterrae.net/kougo/html/colossians.html",
            4,
        ),
        ListItem::new(
            "テサロニケ人への第一の手紙",
            "http://bible.salterrae.net/kougo/html/1thessalonians.html",
            5,
        ),
        ListItem::new(
            "テサロニケ人への第二の手紙",
            "http://bible.salterrae.net/kougo/html/2thessalonians.html",
            3,
        ),
        ListItem::new(
            "テモテヘの第一の手紙",
            "http://bible.salterrae.net/kougo/html/1timothy.html",
            6,
        ),
        ListItem::new(
            "テモテヘの第二の手紙",
            "http://bible.salterrae.net/kougo/html/2timothy.html",
            4,
        ),
        ListItem::new(
            "テトスヘの手紙",
            "http://bible.salterrae.net/kougo/html/titus.html",
            3,
        ),
        ListItem::new(
            "ピレモンヘの手紙",
            "http://bible.salterrae.net/kougo/html/philemon.html",
            1,
        ),
        ListItem::new(
            "ヘブル人への手紙",
            "http://bible.salterrae.net/kougo/html/hebrews.html",
            13,
        ),
        ListItem::new(
            "ヤコブの手紙",
            "http://bible.salterrae.net/kougo/html/james.html",
            5,
        ),
        ListItem::new(
            "ペテロの第一の手紙",
            "http://bible.salterrae.net/kougo/html/1peter.html",
            5,
        ),
        ListItem::new(
            "ペテロの第二の手紙",
            "http://bible.salterrae.net/kougo/html/2peter.html",
            3,
        ),
        ListItem::new(
            "ヨハネの第一の手紙",
            "http://bible.salterrae.net/kougo/html/1john.html",
            5,
        ),
        ListItem::new(
            "ヨハネの第二の手紙",
            "http://bible.salterrae.net/kougo/html/2john.html",
            1,
        ),
        ListItem::new(
            "ヨハネの第三の手紙",
            "http://bible.salterrae.net/kougo/html/3john.html",
            1,
        ),
        ListItem::new(
            "ユダの手紙",
            "http://bible.salterrae.net/kougo/html/jude.html",
            1,
        ),
        ListItem::new(
            "ヨハネの黙示録",
            "http://bible.salterrae.net/kougo/html/revelation.html",
            22,
        ),
    ]
}

fn get_random_value<'a>(testament: Vec<ListItem<'a>>) -> (&'a str, &'a str, String, usize) {
    let mut rng = rand::thread_rng();
    let index = rng.gen_range(0..testament.len());
    let chapter = rng.gen_range(1..=testament[index].max_chapter);
    (
        testament[index].title,
        testament[index].url,
        chapter.to_string(),
        testament[index].max_chapter,
    )
}

fn main() -> Result<()> {
    let setting = init_setting();

    if !setting.old_testament && !setting.new_testament {
        eprintln!("Usage: verse.exe -o/-n [-r]");
        std::process::exit(1);
    }

    let testament = if setting.old_testament {
        get_old_testament()
    } else {
        get_new_testament()
    };

    let (title, url, chapter, max_chapter) = if setting.random {
        get_random_value(testament)
    } else {
        let mut terminal = init_terminal()?;

        let app = App::new(testament);
        let (title, url, chapter, max_chapter) = run_app(&mut terminal, app).unwrap();

        reset_terminal()?;
        terminal.show_cursor()?;

        (title, url, chapter, max_chapter)
    };

    let result = get_verse(url, &chapter);

    print!("{}", result);
    println!("{} {}({}/{})", url, title, chapter, max_chapter);

    Ok(())
}
