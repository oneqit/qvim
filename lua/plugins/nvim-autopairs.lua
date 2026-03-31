return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    -- 커서 뒤에 공백이 아닌 문자가 있으면 쌍을 만들지 않음
    ignored_next_char = "%S",
  },
}
