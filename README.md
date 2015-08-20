# sjChatScan

Scans channel messages for search patterns using Lua regex and does something when there's a match.

Currently only shows the matched message as a notifcation with the match highlighted.

```
## Interface: 11200
## Title: sjChatScan
## Author: SweedJesus (Miraculin on Nostalrius)
## Note: Scans channel messages for search patterns using Lua regex and does something when there's a match. 
## X-Website: https://gitgud.io/SweedJesus/sjChatScan
## X-Category: Chat
## DefaultState: Enabled
## SavedVariables: sjChatScan_DB
```

## Usage

### Patterns
    
-   [Lua Manual on patterns](http://www.lua.org/manual/5.1/manual.html#5.4.1)

#### Examples:

-   `heal` matches: <font color=purple>heal</font>er / <font color=purple>HEAL</font>S
-   `lf%d*m` matches <font color=purple>lfg</font> / <font color=purple>LF2M</font> / <font color=purple>LF9M</font>

### Command table

-   `/sjcs`: Show top level menu options.
-   `/sjcs channels `:  Toggle channels to scan.
-   `/sjcs patterns`:  Show pattern options.
-   `/sjcs patterns list`:  List saved patterns.
-   `/sjcs patterns add <pattern>`:  Add a pattern.
-   `/sjcs patterns remove <index>`:  Remove a pattern via index.
-   `/sjcs color [hex-code]`:  Set the highlight color.

## TODO

-   Control the case [in]sensitivity
-   Exclusion patterns
-   Channel specific pattern lists
-   Integration with a fully-fledged chat addon like Prat or ChatMOD
