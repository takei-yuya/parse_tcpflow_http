#!/usr/bin/env bash

export CR=$'\r'
export LF=$'\n'

run()
{
  exec 2<"${1}.${2}-${3}.${4}" # Local to HTTP Server
  exec 3<"${3}.${4}-${1}.${2}" # HTTP Server to Local

  #
  # Read Request
  #
  request_host="${3}" # In the case the request have no Host header (HTTP/1.0)
  while read -d $'\n' send_line <&2; do
    send_line="${send_line%${CR}}"
    echo "SEND LINE: $send_line"

    # Request line
    if [ "${request_path}" = "" ]; then
      request=(${send_line})
      request_path="${request[1]}"
      continue
    fi

    # Request Headers
    case "${send_line}" in
      Host:*)
      request_host="${send_line#Host: }"
      ;;

      "")
      #
      # Read Response
      #
      code=""
      while read -d $'\n' recv_line <&3; do
        recv_line="${recv_line%${CR}}"
        echo "RECV LINE: ${recv_line}"

        # Status Line
        if [ "${code}" = "" ]; then
          status_line=(${recv_line})
          code="${status_line[1]}"
          content_length=0
          continue
        fi

        # Response Headers
        case "${recv_line}" in
          Content-Length:*)
          content_length="${recv_line#Content-Length: }"
          ;;

          "")
          # Response Body
          echo "Try to read ${content_length} bytes to ${request_host}${request_path}"
          output="${request_host}${request_path}"
          mkdir -p "$(dirname "${output}")"
          dd bs=1 count="${content_length}" of="${output}" <&3
          break
          ;;

        esac
      done
      unset request_path
      ;;

    esac
  done
}

parse_http()
{
  local src="${1%-*}"
  local dest="${1#*-}"

  local src_host="${src%.*}"
  local dest_host="${dest%.*}"

  local src_port="${src##*.}"
  local dest_port="${dest##*.}"

  if [ "${src_port}" = "00080" ]; then
    send_host="${dest_host}"
    send_port="${dest_port}"
    recv_host="${src_host}"
    recv_port="${src_port}"
  elif [ "${dest_port}" = "00080" ]; then
    send_host="${src_host}"
    send_port="${src_port}"
    recv_host="${dest_host}"
    recv_port="${dest_port}"
  fi

  run ${send_host} ${send_port} ${recv_host} ${recv_port}
}

for i in "${@}"; do
  parse_http "${i}"
done
