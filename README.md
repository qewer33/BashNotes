![banner](https://raw.githubusercontent.com/qewer33/BashNotes/main/assets/banner.png)

BashNotes is a simple bash script for managing notes. It allows you to manage your notes in tags (categories) all from your terminal. It is currently not yet finished, still needs some improvements and code cleanup but it mainly works.

### Installation
Download `bashnotes` and `install.sh` (make sure they are on the same directory) and run `install.sh` with root perms:
```
sudo sh install.sh
```

### All Options
```
bashnotes help                        : Shows the help menu for BashNotes
bashnotes create <note_name>          : Creates a note with the given name and opens it in the default editor (add the --no flag before the filename if you don't want it opened after creation)
bashnotes delete <note_name>          : Deletes the note with the given name
bashnotes edit <note_name>            : Opens the given note in the default editor
bashnotes info <note_name>            : Shows information about the given note
bashnotes list <tag>                  : Lists all notes that belong to the given tag (lists all notes if no tag name is given)
bashnotes search <search>             : Searches for the given search term in note names
bashnotes tag <note_name> <tag_name>  : Assigns the given tag to the given note
bashnotes untag <note_name>           : Removes the current tag from the given note
bashnotes taglist                     : Lists all tags
```

### Config Preferences
There are currently 4 config Preferences that you can change:
```
BASE_LOCATION       (default: ~/.config/BashNotes)
NOTES_LOCATION      (default: ${BASE_LOCATION}/notes)
DEFAULT_EDITOR      (default: nano)
DEFAULT_EXTENSION   (default: .txt)
```
