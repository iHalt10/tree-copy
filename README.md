# Tree Copy (Made of bash)
Collect files nested by folders into one folder.

bash version: '>= bash-3.x'

## INSTALLATION
```sh
$ export APP_DIR="${HOME}/.tree_copy"
$ export INSTALL_BIN_PATH="${HOME}/.local/bin"
$ git clone https://github.com/iHalt10/tree-copy.git "${APP_DIR}"
$ cd "${APP_DIR}"
$ make install
```

## UNINSTALLATION
```sh
$ export APP_DIR="${HOME}/.tree_copy"
$ export INSTALL_BIN_PATH="${HOME}/.local/bin"
$ cd "${APP_DIR}"
$ make uninstall
$ cd ../; rm -rf "${APP_DIR}"
```

## OPTIONS
```
-n, --nameing-type <NamingType>   : Determining the name of the file to be copied. (default: kn)
                                    If there is an extension, it remains in the determined file name.
                                    <NamingTypes>
                                    - 'numbering' (short: 'n')
                                      ./src/a.txt   => ./dist/0.txt
                                      ./src/b/a.txt => ./dist/1.txt
                                      ./src/b/c.txt => ./dist/2.txt
                                      ./src/d       => ./dist/3
                                    - 'keep-and-numbering' (short: 'kn')
                                      ./src/a.txt   => ./dist/a.txt
                                      ./src/b/a.txt => ./dist/a (1).txt
                                      ./src/b/c.txt => ./dist/c.txt
                                      ./src/d       => ./dist/d
                                    - 'uuid' (short: 'u')
                                      ./src/a.txt   => ./dist/D3E92237-B5D7-4647-99B1-637E45FC74A7.txt
                                      ./src/b/a.txt => ./dist/338DB1F8-E4DC-4030-BA39-64034243A458.txt
                                      ./src/b/c.txt => ./dist/79E1E60A-3D10-47FE-8767-281DEA52991F.txt
                                      ./src/d       => ./dist/d
                                    - 'uid-upper' (short: 'up')
                                      ./src/a.txt   => ./dist/15B2C356FD364E9ABFBACFA0CA5B9FC7.txt
                                      ./src/b/a.txt => ./dist/5D2420A1C54745E386203672A233EBA2.txt
                                      ./src/b/c.txt => ./dist/D92032E3888F4B5CA179D3786750752F.txt
                                      ./src/d       => ./dist/9CA57511ACD74BB99ED23504298CDC06
                                    - 'uid-lower' (short: 'lo')
                                      ./src/a.txt   => ./dist/9fe37ec5e7754689aef63c7813b70029.txt
                                      ./src/b/a.txt => ./dist/cbb52770b2064578a0f9995ac3959586.txt
                                      ./src/b/c.txt => ./dist/1542fe5aedbc41329167875a390550f4.txt
                                      ./src/d       => ./dist/63f39c358e184d71885f2de4c1548ee9
-m, --maxdepth <Numeric>          : Depth of source directory to be copied. (default: 3)
-s, --src-dir <Path>              : Specify the directory you want to collect.　(default './')
-d, --dist-dir <Path>             : Specify the copy destination directory. (default './')
--sort <SortType>                 : Copy in sort order. SortTypes are 'asc' or 'desc' or 'disable'. (default: 'asc')
                                    It strongly affects the 'numbering' of Naming Type.
-f, --filter <FilterType> <List>  : File paths that contain certain characters are filtered.
                                    example: -f include "jpg,png"
                                    <FilterType>
                                    - include
                                      File paths that contain certain characters are included.
                                    - exclude
                                      File paths that contain certain characters are excluded.
                                    <List>
                                    Specify them separated by commas.
--create                          : Create a copy destination directory. (default: false)
--delete                          : After copying the file, delete it. (default: false)
--dry-run                         : Not run copy and delete. (default: false)
--debug                           : print debug. (default: false)
--version                         : print version.
-h, --help                        : print help.
```

## EXAPLE
Collect "jpg" and "png" in the download folder.
```sh
$ tcp -s ~/Downloads/ -d ~/Desktop/img/ --create -f include "jpg,png" --maxdepth 1
```
