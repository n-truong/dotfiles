" Vim compiler file
" Compiler:   Haskell Stack
" Maintainer: Nicholas Truong <me@n-truong.com>

if exists("current_compiler")
  finish
endif
let current_compiler = "stack"

let s:cpo_save = &cpo
set cpo&vim

CompilerSet makeprg=stack\ build

CompilerSet errorformat=
  \%-G%.%#:\ build\ %.%#,
  \%-G%.%#:\ configure\ %.%#,
  \%-G[%.%#]%.%#,
  \%-G%.%#preprocessing\ %.%#,
  \%-G%.%#configuring\ %.%#,
  \%-G%.%#building\ %.%#,
  \%-G%.%#linking\ %.%#,
  \%-G%.%#installing\ %.%#,
  \%-G%.%#registering\ %.%#,
  \%-G%.%#:\ copy/register%.%#,
  \%-G%.%#process\ exited\ %.%#,
  \%-G%.%#--builddir=%.%#,
  \%-G--%.%#,
  \%-G%.%#\|%.%#,
  \%E%f:%l:%c:\ error:,%+Z\ \ \ \ %m,
  \%E%f:%l:%c:\ error:\ %m,%-Z,
  \%W%f:%l:%c:\ warning:,%+Z\ \ \ \ %m,
  \%W%f:%l:%c:\ warning:\ %m,%-Z,

let &cpo = s:cpo_save
unlet s:cpo_save
