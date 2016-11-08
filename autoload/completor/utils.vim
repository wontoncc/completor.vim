function! completor#utils#tempname()
  let tmp = escape(tempname(), ' ')
  let ext = expand('%:p:e')
  let ext = empty(ext) ? '' : '.'.ext
  let tmp .= ext
  call writefile(getline(1, '$'), tmp)
  return tmp
endfunction


function! completor#utils#get_completer(ft, inputted)
Py << EOF
args = vim.bindeval('a:')
c = completor.load_completer(args['ft'], args['inputted'])
info = [c.format_cmd(), c.filetype, c.daemon, c.sync] if c else []
completor.current = c
EOF
  return Pyeval('info')
endfunction


function! completor#utils#get_completions(msg)
Py << EOF
c = completor.current
result = c.get_completions(vim.bindeval('a:')['msg']) if c else []
EOF
  return Pyeval('result')
endfunction


function! completor#utils#retrigger()
Py << EOF
c = completor.current
info = []
if c and c.filetype != 'common':
  c = completor.get('common', c.ft, c.input_data)
  completor.current = c
  info = [c.format_cmd(), c.filetype, c.daemon, c.sync]
EOF
  let info = Pyeval('info')
  if empty(info) | return | endif
  let [cmd, ft, daemon, is_sync] = info
  call completor#do_complete(cmd, ft, daemon, is_sync)
endfunction


function! completor#utils#get_start_column()
  return Pyeval('completor.current.start_column() if completor.current else -1')
endfunction


function! completor#utils#daemon_request()
  return Pyeval('completor.current.request() if completor.current else ""')
endfunction


function! completor#utils#add_buffer_request()
Py << EOF
common = completor.get('common')
req, cmd = '', ''
if common and common.daemon:
  req = common.request(action='add')
  cmd = common.format_cmd()
EOF
  return [Pyeval('req'), Pyeval('cmd')]
endfunction


function! completor#utils#message_ended(msg)
Py << EOF
msg = vim.bindeval('a:')['msg']
ended = completor.current.message_ended(msg) if completor.current else False
EOF
  return Pyeval('ended')
endfunction


function! completor#utils#load()
Py << EOF
import completor, vim
import completers.common
EOF
endfunction
