import compress.szip
import net.http
import os
import x.json2

// How to build.
// v -cc msvc -prod v_update.v

fn main() {
	url := 'https://api.github.com/repos/vlang/v/releases/latest'

	resp := http.get(url)!
	assert resp.status() != .not_found, 'Not found URL: ${url}'

	raw_product := json2.raw_decode(resp.body)!

	product := raw_product.as_map()

	data := product as map[string]json2.Any

	assets := (data['assets'] or { panic('key ("assets") not found') }) as []json2.Any

	mut dl_url := ''

	for asset in assets {
		name := ((asset as map[string]json2.Any)['name'] or { panic('key ("name") not found') }).str()

		if 'v_windows.zip' == name {
			dl_url = ((asset as map[string]json2.Any)['browser_download_url'] or {
				panic('key ("browser_download_url") not found')
			}).str()
		}
	}

	http.download_file(dl_url, '${os.home_dir()}\\Downloads\\v_windows.zip')!

	if os.exists('C:\\Langs\\v') {
		os.rmdir_all('C:\\Langs\\v')!
	}

	szip.extract_zip_to_dir('${os.home_dir()}\\Downloads\\v_windows.zip', 'C:\\Langs')!

	os.rm('${os.home_dir()}\\Downloads\\v_windows.zip')!
}
