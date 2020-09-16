# Tasks for the Project
* Task 1
* Follow up task 1 [here](followuptask0.md)
* Follow up task 2 [here](followuptask1.md)

## Task-1

### Subtask 1
* Create a list of all non-merge commits that were added in the version v5.8 of the kernel, i.e., all non-merge commits that are in v5.8 and not already in v5.7<br><br>

**Command for Listing commits**<br>
```
git log --oneline --no-merges v5.8 ^v5.7
# or
git log --oneline --no-merges v5.7..v5.8
```
<br>

**Output**<br>
Complete list of commits in [file here](workingdir/commit_list_in5.8_and_not5.7)<br>
Script used can be [viewed here](populate.sh#L9)
```
$ git log --oneline --no-merges v5.8 ^v5.7
bcf876870b95 (tag: v5.8) Linux 5.8
28ab576ba8de kbuild: remove redundant FORCE definition in scripts/Makefile.modpost
ccf56e5fe3d2 kconfig: qconf: remove wrong ConfigList::firstChild()
fda2ec62cf1a vxlan: fix memleak of fdb
4b20e103a63d Revert "kconfig: qconf: don't show goback button on splitMode"
97bebbcd8b93 Revert "kconfig: qconf: Change title for the item window"
ce02397f44e9 kconfig: qconf: remove "goBack" debug message
c9b09a9249e6 kconfig: qconf: use delete[] instead of delete to free array
0e912c032080 kconfig: qconf: compile moc object separately
c3cd7cfad51a kconfig: qconf: use if_changed for qconf.moc rule
:
```
**Total count of commits**
```
ujjwal 12:06:11 (master) linux-next 
$ git log --oneline --no-merges v5.8 ^v5.7 | wc -l
16306
```
<br>

### Subtask 2
* Run your script on all commits of this list above and record all checkpatch.pl reports, and store them in your github repository

**Run script on all the commits and show types (this will include merge commits)**
```
scripts/checkpatch.pl -g v5.7..v5.8 --show-types
```

**Print oneline warnings/errors**
```
scripts/checkpatch.pl -g v5.7..v5.8 --terse --show-types
```
All generated errors and warnings by the script available in [file here](workingdir/checkpatch_result).<br>
Script used can be [viewed here](populate.sh#L27).
<br><br>
### Subtask 3
**How to aggregate the findings and create a statistics?**
* List of commits based on *attention level (ERROR/WARNING/CHECK)*
* List of commits based on *Type of message*
* Count of occurrence of each Type of message
* Count of commits containing a Type of message

All statistics available in [file here](workingdir/stats).<br>
Script used can be [viewed here](populate.sh#L119).
<br><br>

**Which type of error is reported most?**
* Errors
```
   1092 ERROR:OPEN_BRACE
   1039 ERROR:SPACING
    904 ERROR:TRAILING_WHITESPACE
    660 ERROR:COMPLEX_MACRO
    342 ERROR:CODE_INDENT
    272 ERROR:GIT_COMMIT_ID
    120 ERROR:TRAILING_STATEMENTS
    109 ERROR:POINTER_LOCATION
     36 ERROR:GLOBAL_INITIALISERS
     36 ERROR:FUNCTION_WITHOUT_ARGS
     27 ERROR:ASSIGN_IN_IF
     26 ERROR:ELSE_AFTER_BRACE
     20 ERROR:SWITCH_CASE_INDENT_LEVEL
     14 ERROR:BAD_SIGN_OFF
     11 ERROR:INITIALISED_STATIC
     10 ERROR:BRACKET_SPACE
      9 ERROR:MULTISTATEMENT_MACRO_USE_DO_WHILE
      7 ERROR:DIFF_IN_COMMIT_MSG
      6 ERROR:FSF_MAILING_ADDRESS
      5 ERROR:RETURN_PARENTHESES
      4 ERROR:DEFINE_ARCH_HAS
      3 ERROR:EXECUTE_PERMISSIONS
      2 ERROR:INLINE_LOCATION
      2 ERROR:IN_ATOMIC
      1 ERROR:WHILE_AFTER_BRACE
```
* Warnings
```
   4906 WARNING:LEADING_SPACE
   3511 WARNING:LONG_LINE
   1741 WARNING:BLOCK_COMMENT_STYLE
   1712 WARNING:EMBEDDED_FUNCTION_NAME
   1389 WARNING:REPEATED_WORD
   1319 WARNING:SPDX_LICENSE_TAG
   1269 WARNING:LONG_LINE_COMMENT
   1257 WARNING:UNSPECIFIED_INT
   1059 WARNING:COMMIT_LOG_LONG_LINE
   1039 WARNING:FILE_PATH_CHANGES
    788 WARNING:SPACE_BEFORE_TAB
    670 WARNING:LONG_LINE_STRING
    616 WARNING:FUNCTION_ARGUMENTS
    609 WARNING:SPLIT_STRING
    597 WARNING:LINE_SPACING
    419 WARNING:NEW_TYPEDEFS
    375 WARNING:DT_SPLIT_BINDING_PATCH
    322 WARNING:TYPO_SPELLING
    286 WARNING:NO_AUTHOR_SIGN_OFF
    280 WARNING:BAD_SIGN_OFF
    218 WARNING:BRACES
    171 WARNING:SPACING
    158 WARNING:COMMIT_MESSAGE
    146 WARNING:RETURN_VOID
    126 WARNING:VOLATILE
    117 WARNING:SUSPECT_CODE_INDENT
    109 WARNING:AVOID_BUG
    107 WARNING:PRINTK_WITHOUT_KERN_LEVEL
     97 WARNING:CONFIG_DESCRIPTION
     89 WARNING:LOGGING_CONTINUATION
     83 WARNING:UNDOCUMENTED_DT_STRING
     83 WARNING:QUOTED_WHITESPACE_BEFORE_NEWLINE
     76 WARNING:MULTILINE_DEREFERENCE
     65 WARNING:MEMORY_BARRIER
     65 WARNING:AVOID_EXTERNS
     64 WARNING:CONSTANT_COMPARISON
     58 WARNING:NETWORKING_BLOCK_COMMENT_STYLE
     58 WARNING:ENOTSUPP
     57 WARNING:SINGLE_STATEMENT_DO_WHILE_MACRO
     53 WARNING:PREFER_FALLTHROUGH
     47 WARNING:DATA_RACE
     44 WARNING:USE_NEGATIVE_ERRNO
     42 WARNING:PREFER_PR_LEVEL
     41 WARNING:IF_0
     38 WARNING:USE_RELATIVE_PATH
     38 WARNING:SYMBOLIC_PERMS
     37 WARNING:UNNECESSARY_ELSE
     33 WARNING:TABSTOP
     31 WARNING:MAINTAINERS_STYLE
     26 WARNING:UNKNOWN_COMMIT_ID
     25 WARNING:PREFER_SEQ_PUTS
     23 WARNING:VSPRINTF_SPECIFIER_PX
     22 WARNING:UNNECESSARY_BREAK
     22 WARNING:LINE_CONTINUATIONS
     21 WARNING:OBSOLETE
     21 WARNING:ENOSYS
     18 WARNING:PREFER_DEV_LEVEL
     18 WARNING:EMAIL_SUBJECT
     17 WARNING:MSLEEP
     17 WARNING:DEEP_INDENTATION
     17 WARNING:CONST_STRUCT
     16 WARNING:OOM_MESSAGE
     16 WARNING:MACRO_WITH_FLOW_CONTROL
     14 WARNING:STATIC_CONST_CHAR_ARRAY
     14 WARNING:EXPORT_SYMBOL
     11 WARNING:SUSPECT_COMMA_SEMICOLON
     11 WARNING:ALLOC_WITH_MULTIPLY
     10 WARNING:PRINTF_L
      9 WARNING:TYPECAST_INT_CONSTANT
      8 WARNING:TRAILING_SEMICOLON
      8 WARNING:INDENTED_LABEL
      7 WARNING:PREFER_ALIGNED
      7 WARNING:MINMAX
      7 WARNING:DT_SCHEMA_BINDING_PATCH
      7 WARNING:DEVICE_ATTR_FUNCTIONS
      6 WARNING:CONSIDER_KSTRTO
      5 WARNING:UNNECESSARY_PARENTHESES
      5 WARNING:MISPLACED_INIT
      5 WARNING:INLINE
      5 WARNING:INCLUDE_LINUX
      4 WARNING:PREFER_PACKED
      4 WARNING:PREFER_IS_ENABLED
      4 WARNING:NEEDLESS_IF
      4 WARNING:DEVICE_ATTR_PERMS
      3 WARNING:USE_LOCKDEP
      3 WARNING:USE_FUNC
      3 WARNING:UNNECESSARY_INT
      3 WARNING:ONE_SEMICOLON
      3 WARNING:NR_CPUS
      3 WARNING:IF_1
      2 WARNING:UNNECESSARY_KERN_LEVEL
      2 WARNING:TRACE_PRINTK
      2 WARNING:SIZEOF_PARENTHESIS
      2 WARNING:PREFER_SECTION
      2 WARNING:MISSING_EOF_NEWLINE
      2 WARNING:LINUX_VERSION_CODE
      2 WARNING:DO_WHILE_MACRO_WITH_TRAILING_SEMICOLON
      1 WARNING:YIELD
      1 WARNING:WAITQUEUE_ACTIVE
      1 WARNING:STORAGE_CLASS
      1 WARNING:PREFER_PRINTF
      1 WARNING:MISSING_SPACE
      1 WARNING:LIKELY_MISUSE
      1 WARNING:KREALLOC_ARG_REUSE
      1 WARNING:IS_ENABLED_CONFIG
      1 WARNING:ARRAY_SIZE
      1 WARNING:ALLOC_ARRAY_ARGS
```
