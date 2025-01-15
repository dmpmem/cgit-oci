use std::io::BufRead;

use pulldown_cmark::{html, Options, Parser};

fn main() {
  let stdin = std::io::stdin();
  let mut markdown_input = format!("");
  let mut disabled = false;
  for line in stdin.lock().lines() {
    let mut line = line.unwrap();
    if disabled && line.contains("<!-- !END-NO-CGIT! -->") {
      disabled = false;
      line = line.replace("!END-NO-CGIT!", "Removed Block");
    }
    if !disabled {
      if line.contains("<!-- !BEGIN-NO-CGIT! -->") {
        disabled = true
      } else if !line.contains("<!-- NO-CGIT -->") {
        markdown_input = format!("{markdown_input}{line}\n")
      }
    }
  }

  let mut options = Options::empty();
  options.insert(Options::ENABLE_STRIKETHROUGH);
  options.insert(Options::ENABLE_FOOTNOTES);
  options.insert(Options::ENABLE_TABLES);
  options.insert(Options::ENABLE_TASKLISTS);
  options.insert(Options::ENABLE_YAML_STYLE_METADATA_BLOCKS);
  options.insert(Options::ENABLE_HEADING_ATTRIBUTES);
  options.insert(Options::ENABLE_GFM);
  let parser = Parser::new_ext(&markdown_input, options);
  let mut html_output: String = String::with_capacity(markdown_input.len() * 3 / 2);
  html::push_html(&mut html_output, parser);
  println!("<style>@import url(\"/assets/md.css\")</style><div class=\"md\">{html_output}</div>")
}
