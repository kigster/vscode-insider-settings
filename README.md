## Visual Studio Code Settings Manager

This repo is a simple toolkit around managing VSCode settings.

You may be aware that VSCode is distributed in both the stable public version (called just `vscode` here), or
the cutting-edge ["Insiders Build"](https://code.visualstudio.com/blogs/2016/05/23/evolution-of-insiders).

The insiders build has many latest developments, and in particular it's integrated Terminal does not take five seconds to respond to your keystrokes :) 

Long story short, you might want to switch to using Insiders Build instead of the regular VSCode. 

But how do you keep your extensions and settings? — This is where this repo comes in.

Using the `Makefile` provided, you can:

| Syntax | Description |
| --- | ----------- |
| Header | Title |
| Paragraph | Text |

 *  Install VSCode and/or VSCode Insiders Edition
 * Backup/export the list of VSCode Extensions into a text files
 * Install the VSCode extensions using a previous export file
 * Creates command launchers without having to do this manually
 * Finally, it can install a bunch of excellent mono-spaced fonts from an open source collection.

 ## Usage

 Run `make` without any arguments:

```
❯ make

dump-extensions-vscode-insiders          Exports list of extensions of VSCode Insiders to extensions.txt
dump-extensions-vscode                   Exports list of extensions of VSCode to extensions.txt
dump                                     Dumps both Insiders and Standard settings, if available

import-extensions-vscode-insiders        Import extensions from extensions.txt into VSCode Insiders
import-extensions-vscode                 Import extensions from extensions.txt into VSCode

install-fonts                            Install a slew of excellent open-source Mono-Spaced fonts for the IDE & Terminal
install-launchers                        Install command launchers for VSCode and VSCode Insiders
install-vscode-insiders                  Install VSCode-Insiders using brew
install-vscode                           Install VSCode using brew

vscode-insiders                          Installs VSCode Insiders Edition, mono-fonts, and the extensions
vscode-standard                          Installs VSCode Regular Edition, mono-fonts, and the extensions
`
import-standard-to-insiders              Import standard settings from VSCode into Insiders Edition
```

This should be self explanatory.
