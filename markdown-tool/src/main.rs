use std::io::BufRead;

use pulldown_cmark::{html, Options, Parser};

fn main() {
  let stdin = std::io::stdin();
  let mut markdown_input = format!("");
  for line in stdin.lock().lines() {
    markdown_input = format!("{markdown_input}{}\n", line.unwrap())
  }

  let mut options = Options::empty();
  options.insert(Options::ENABLE_STRIKETHROUGH);
  options.insert(Options::ENABLE_FOOTNOTES);
  options.insert(Options::ENABLE_TABLES);
  options.insert(Options::ENABLE_TASKLISTS);
  options.insert(Options::ENABLE_YAML_STYLE_METADATA_BLOCKS);
  options.insert(Options::ENABLE_GFM);
  let parser = Parser::new_ext(&markdown_input, options);
  let mut html_output: String = String::with_capacity(markdown_input.len() * 3 / 2);
  html::push_html(&mut html_output, parser);
  println!("<style>@import url(\"/assets/md.css\")</style><div class=\"md\">{html_output}</div>")
}
