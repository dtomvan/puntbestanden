;extends
(fenced_code_block
  (info_string
    (language) @language
    (#eq? @language "space-lua"))
  (code_fence_content) @injection.content
  (#set! injection.language "lua"))

(fenced_code_block
  (info_string
    (language) @language
    (#eq? @language "space-style"))
  (code_fence_content) @injection.content
  (#set! injection.language "css"))

