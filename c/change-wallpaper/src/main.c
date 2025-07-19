#include <locale.h>
#include <stdio.h>

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#include <shlwapi.h>

int wmain(int argc, wchar_t *argv[])
{
    setlocale(LC_ALL, "Japanese");

    if (argc != 2) {
        wprintf(L"Usage: %s [FILEPATH]", argv[0]);
        return 1;
    }

    if (!PathFileExists(argv[1])) {
        wprintf(L"Not found: %s", argv[1]);
        return 1;
    }

    int ret = SystemParametersInfo(
            SPI_SETDESKWALLPAPER,
            0,
            argv[1],
            SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE);

    if (!ret) {
        wprintf(L"Error: failed to change a wallpaper (%d)\n", GetLastError());
        return 1;
    }

    return 0;
}
