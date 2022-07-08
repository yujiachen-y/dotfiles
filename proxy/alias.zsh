PROXY_PORT="7890"
alias proxy="export https_proxy=http://127.0.0.1:$PROXY_PORT http_proxy=http://127.0.0.1:$PROXY_PORT all_proxy=socks5://127.0.0.1:$PROXY_PORT"
alias unproxy="unset http_proxy;unset https_proxy"
withproxy () {
https_proxy=http://127.0.0.1:"$PROXY_PORT" http_proxy=http://127.0.0.1:"$PROXY_PORT" all_proxy=socks5://127.0.0.1:"$PROXY_PORT" $*
}
