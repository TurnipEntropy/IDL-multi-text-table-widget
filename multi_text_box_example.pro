pro multi_text_box_example_EVENT, event
  widget_control, event.id, get_uvalue = widget
  print, event.id
  print, event.top

  widget_control, event.top, get_uvalue = response_ptr
  response = *response_ptr
  return_struct = {text_boxes: ptr_new()}
  print, widget
  case widget of
    'Change values':begin
      text_box_ids = *(response.text_boxes)
      text_boxes = make_array(size(text_box_ids, /dimensions))
      counter = 0
      foreach id, text_box_ids do begin
        widget_control, id, get_value = text_box
        text_boxes[counter] = text_box
        counter += 1
      endforeach
      return_struct.text_boxes = ptr_new(text_boxes)
      response = return_struct
    end

  endcase

  *response_ptr = response
  widget_control, event.top, /destroy
end

pro multi_text_box_example
  points = randomn(0, [2, 14])
  n_points = n_elements(points[0, *])
  text_box_titles = make_array(2, n_points + 1, /string)
  text_box_titles[*, 0] = ['x (L/R)', 'y (U/D)']
  for i = 1, n_points do begin
    text_box_titles[*, i] = ['Point' + string(i), '']
  endfor
  initial_text_values = string(points)
  multi_response = {text_boxes:ptr_new()}
  multi_response_ptr = ptr_new(multi_response)
  ;button text, and button width
  button = ['Change values', '120']
  create_multi_text_input_widget,"test", 0, 0, n_points * 2, multi_response_ptr, $
    text_box_titles = text_box_titles, $
    initial_text_values = initial_text_values, button = button
  multi_response = *multi_response_ptr
  points = *(multi_response.text_boxes)
  ;points now contains the updated values from the mulit_text_input_widget, which
  ;the next widget will display
  initial_text_values = string(points)
  create_multi_text_input_widget,"test", 0, 0, n_points * 2, multi_response_ptr, $
    text_box_titles = text_box_titles, $
    initial_text_values = initial_text_values, button = button
end

pro create_multi_text_input_widget, title, xoffset, yoffset, num_text_boxes, response_ptr, $
  text_box_titles = text_box_titles, num_rows = num_rows, num_cols = num_cols, $
  initial_text_values = initial_text_values, button = button

  TOO_MANY_ARGUMENTS_TOO_FEW_DIMENSIONS = "If you want to have more text box titles than rows or columns of text boxes, you need to place them in an array matching the arrangment of the text boxes."
  ;Assumes no responsibility for the creation of an event handler or proper event
  ;handling.
  ;
  ;title: title of the base widget
  ;xoffset and yoffset: offsets of base widget
  ;num_text_boxes: number of text boxes that are going to be created
  ;                in this widget
  ;response_ptr: the pointer supplied to hold results of this widget
  ;num_rows: the number of rows of text boxes
  ;num_cols: the number of columns of text boxes
  ;text_box_titles: any text to be placed above or next to the text boxes
  ;initial_text_values: the initial values to be shown in the text fields. If
  ;                     num_rows or num_cols are not included in the function call, they are
  ;                     determined through the size of this array. If this isn't included,
  ;                     then the default of 1 column, enough rows to hold num_text_boxes
  ;                     is used.
  ;button: all of the information about the button is required to be sent in this variable
  ;        including button label and size.


  if not keyword_set(num_cols) then begin
    if not keyword_set(initial_text_values) then begin
      num_cols = 1
      num_rows = num_text_boxes
    endif else begin
      text_values_size = size(initial_text_values, /dimensions)
      if (n_elements(text_values_size) eq 1) then begin
        num_cols = 1
        num_rows = num_text_boxes
      endif else begin
        num_cols = text_values_size[0]
        num_rows = text_values_size[1]
      endelse
    endelse
  endif

  row_labels = 0
  col_labels = 0
  if keyword_set(text_box_titles) then begin
    text_titles_size = size(text_box_titles, /dimensions)
    case n_elements(text_titles_size) of
      1:case text_titles_size[0] of
      num_cols: begin
        num_cols += 1
        col_labels = 1
      end
      num_rows: begin
        num_rows += 1 ;there are problems if it's neither...
        row_labels = 1
      end
      default: message, TOO_MANY_ARGUMENTS_TOO_FEW_DIMENSIONS
    endcase
    2:begin
      if (text_titles_size[0] eq num_cols and text_titles_size[1] eq num_rows + 1) then begin
        num_cols += 1
        row_labels = 1
        col_labels = 1
      endif
      end
    endcase
  endif
  num_rows += 1
  put_button = keyword_set(button)
  if (put_button) then begin
    base = widget_base(row = num_rows + 1, title = title, xoffset = xoffset, $
      yoffset = yoffset, tlb_frame_attr = 1)
  endif else begin
    base = widget_base(row = num_rows, title = title, xoffset = xoffset, $
      yoffset = yoffset, tlb_frame_attr = 1)
  endelse

  text_widgets = make_array(num_cols - 1, num_rows - 1)
  text_widgets[0, 0] = widget_text(base, value = "")
  counter = 0
  for i = 1, num_cols - 1 do begin
    text_widgets[0, i] = widget_text(base, value = text_box_titles[counter])
    counter += 1
  endfor
  for i = 0, num_text_boxes - 1 do begin
    if (i mod (num_cols - 1) eq 0) then begin
      temp = widget_text(base, value = text_box_titles[counter])
      counter += 2
    endif
    text_widgets[i] = widget_text(base, uvalue = "Text" + string(i), value = initial_text_values[i], $
      tab_mode = 1, /editable)
  endfor
  if (put_button) then begin
    for i = 0, num_cols - 1 do begin
      if (i eq num_cols / 2) then begin
        widgbutton = widget_button(base, value = button[0], uvalue = button[0], xsize = fix(button[1]))
      endif else begin
        empty_text = widget_text(base, value = "")
      endelse
    endfor
  endif
  
  ;Does not currently support row or column titles inside of the editable table range. I do not plan
  ;on adding that support, but this would serve as a starting point for that.

  *response_ptr = {text_boxes:ptr_new(text_widgets)}
  widget_control, base, /realize
  widget_control, base, set_uvalue = response_ptr

  xmanager, 'multi_text_box_example', base

end