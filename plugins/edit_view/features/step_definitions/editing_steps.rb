
def unescape_text(text)
  text.gsub("\\t", "\t").gsub("\\n", "\n").gsub("\\r", "\r").gsub("\\\"", "\"")
end

def escape_text(text)
  text.gsub("\t", "\\t").gsub("\n", "\\n").gsub("\r", "\\r").gsub("\"", "\\\"")
end

When /^I undo$/ do
  Redcar::Top::UndoCommand.new.run
end

When /^I redo$/ do
  Redcar::Top::RedoCommand.new.run
end

When /^I select from (\d+) to (\d+)$/ do |start_offset, end_offset|
  doc = Redcar.app.focussed_window.focussed_notebook.focussed_tab.edit_view.document
  doc.set_selection_range(start_offset.to_i, end_offset.to_i)
end

When /^I copy text$/ do
  Redcar::Top::CopyCommand.new.run
end

When /^I cut text$/ do
  Redcar::Top::CutCommand.new.run
end

When /^I paste text$/ do
  Redcar::Top::PasteCommand.new.run
end

When /^I move the cursor to (\d+)$/ do |offset|
  doc = Redcar.app.focussed_window.focussed_notebook.focussed_tab.edit_view.document
  doc.cursor_offset = offset.to_i
end

Then /^the cursor should be at (\d+)$/ do |offset|
  doc = Redcar::EditView.focussed_tab_edit_view.document
  doc.cursor_offset.should == offset.to_i
end

When /^tabs are hard$/ do
  Redcar::EditView.focussed_tab_edit_view.soft_tabs = false
end

When /^tabs are soft, (\d+) spaces$/ do |int|
  Redcar::EditView.focussed_tab_edit_view.soft_tabs = true
  Redcar::EditView.focussed_tab_edit_view.tab_width = int.to_i
end

When /^I insert "(.*)" at the cursor$/ do |text|
  Redcar::EditView.focussed_edit_view_document.insert_at_cursor(unescape_text(text))
end

When /^I insert "(.*)" at (\d+)$/ do |text, offset_s|
  Redcar::EditView.focussed_edit_view_document.insert(offset_s.to_i, unescape_text(text))
end

When /^I replace (\d+) to (\d+) with "(.*)"$/ do |from, to, text|
  Redcar::EditView.focussed_edit_view_document.replace(from.to_i, to.to_i - from.to_i, unescape_text(text))
end

When /^I press the Tab key in the edit tab$/ do
  edit_view = Redcar::EditView.focussed_tab_edit_view
  edit_view.tab_pressed([])
end

When /^I press Shift\+Tab in the edit tab$/ do
  edit_view = Redcar::EditView.focussed_tab_edit_view
  edit_view.tab_pressed(["Shift"])
end

When /^I press the Left key in the edit tab$/ do
  edit_view = Redcar::EditView.focussed_tab_edit_view
  edit_view.left_pressed([])
end

When /^I press the Right key in the edit tab$/ do
  edit_view = Redcar::EditView.focussed_tab_edit_view
  edit_view.right_pressed([])
end

When /^I press Shift\+Left key in the edit tab$/ do
  edit_view = Redcar::EditView.focussed_tab_edit_view
  edit_view.left_pressed(["Shift"])
end

When /^I press Shift\+Right key in the edit tab$/ do
  edit_view = Redcar::EditView.focussed_tab_edit_view
  edit_view.right_pressed(["Shift"])
end

When /^I press the Delete key in the edit tab$/ do
  edit_view = Redcar::EditView.focussed_tab_edit_view
  edit_view.delete_pressed([])
end

When /^I press the Backspace key in the edit tab$/ do
  edit_view = Redcar::EditView.focussed_tab_edit_view
  edit_view.backspace_pressed([])
end

Then /^the contents should be "(.*)"$/ do |text|
  expected = unescape_text(text)
  doc = Redcar::EditView.focussed_edit_view_document
  actual = doc.to_s
  if expected.include?("<c>")
    curoff = doc.cursor_offset
    actual = actual.insert(curoff, "<c>")
    seloff = doc.selection_offset
    if seloff > curoff
      seloff += 3
    end
    actual = actual.insert(seloff, "<s>") unless curoff == seloff
  end
  actual.should == expected
end

Then /^the contents of the edit tab should be "(.*)"$/ do |text|
  Redcar::EditView.focussed_edit_view_document.to_s.should == unescape_text(text)
end

When /^I block select from (\d+) to (\d+)$/ do |from_str, to_str|
  doc = Redcar::EditView.focussed_edit_view_document
  doc.block_selection_mode = true
  doc.set_selection_range(from_str.to_i, to_str.to_i)
end

Then /^the selection range should be from (\d+) to (\d+)$/ do |from_str, to_str|
  doc = Redcar::EditView.focussed_edit_view_document
  r = doc.selection_range
  r.begin.should == from_str.to_i
  r.end.should == to_str.to_i
end

Then /^the selection should be on line (.*)$/ do |line_num|
  line_num = line_num.to_i
  doc = Redcar::EditView.focussed_edit_view_document
  r = doc.selection_range
  doc.line_at_offset(r.begin).should == line_num
  doc.line_at_offset(r.end).should == line_num
end
 
Then /^there should not be any text selected$/ do
  doc = Redcar::EditView.focussed_edit_view_document
  doc.selected_text.should == ""
end

Then /^the selected text should be "([^"]*)"$/ do |selected_text|
  doc = Redcar::EditView.focussed_edit_view_document
  doc.selected_text.should == selected_text
end

Then /the line delimiter should be "(.*)"/ do |delim|
  doc = Redcar::EditView.focussed_edit_view_document
  doc.delim.should == unescape_text(delim)
end

When /^I move to line (\d+)$/ do |num|
  doc = Redcar::EditView.focussed_edit_view_document
  doc.cursor_offset = doc.offset_at_line(num.to_i)
end

Then /^the cursor should be on line (\d+)$/ do |num|
  doc = Redcar::EditView.focussed_edit_view_document
  doc.cursor_line.should == num.to_i
end

When /^I replace the contents with "([^\"]*)"$/ do |contents|
  contents = unescape_text(contents)
  doc = Redcar::EditView.focussed_edit_view_document
  cursor_offset = (contents =~ /<c>/)
  doc.text = contents.gsub("<c>", "")
  doc.cursor_offset = cursor_offset if cursor_offset
end

When /^I replace the contents with 100 lines of "([^"]*)" then "([^"]*)"$/ do |contents1, contents2|
  contents1 = unescape_text(contents1)
  contents2 = unescape_text(contents2)
  doc = Redcar::EditView.focussed_edit_view_document
  doc.text = (contents1 + "\n")*100 + contents2
end

When /^I scroll to the top of the document$/ do
  doc = Redcar::EditView.focussed_edit_view_document
  doc.scroll_to_line(0)
end

Then /^line number (\d+) should be visible$/ do |line_num|
  line_num = line_num.to_i
  doc = Redcar::EditView.focussed_edit_view_document
  (doc.biggest_visible_line >= line_num).should be_true
  (doc.smallest_visible_line <= line_num).should be_true
end

When /^I select the word (right of|left of|around|at) (\d+)$/ do |direction, offset|
  offset = offset.to_i
  doc = Redcar::EditView.focussed_edit_view_document
  case direction
  when "right of"
    range = doc.match_word_right_of(offset)
  when "left of"
    range = doc.match_word_left_of(offset)
  when "around"
    range = doc.match_word_around(offset)
  when "at"
    range = doc.word_range_at_offset(offset)
  else
    warn "unrecognized direction"
    range = offset..offset
  end
  doc.set_selection_range(range.first, range.last)
end

When /^I turn block selection on$/ do
  Redcar::EditView.focussed_edit_view_document.block_selection_mode?.should == false
  Redcar::Top::ToggleBlockSelectionCommand.new.run
end

When /^I turn block selection off$/ do
  Redcar::EditView.focussed_edit_view_document.block_selection_mode?.should == true
  Redcar::Top::ToggleBlockSelectionCommand.new.run
end

def escape_text(text)
  text.gsub("\t", "\\t").gsub("\n", "\\n").gsub("\r", "\\r").gsub("\"", "\\\"")
end

Given /^the contents? is:$/ do |string|
  cursor_index    = string.index('<c>')
  selection_index = string.index('<s>')
  string = string.gsub('<s>', '').gsub('<c>', '')
  When %{I replace the contents with "#{string}"}
  
  if cursor_index and selection_index 
    if cursor_index < selection_index
      selection_index -= 3
    else
      cursor_index -= 3
    end
    When %{I select from #{selection_index} to #{cursor_index}}
  elsif cursor_index
    When "I move the cursor to #{cursor_index}"
  end
end

Then /^the content? should be:$/ do |string|
  Then %{the contents should be "#{escape_text(string)}"}
end

