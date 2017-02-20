import * as cc from "./chat_channel"
import toastr from 'toastr'
import * as utils from './utils'

// export function init() {
//   $('body').on('click', '.setting-block span.current-setting[data-edit="false"]', dc => {})
//   $('body').on('click', 'li.text .setting-block span.current-setting', function(e) {
//     console.log('click on button!!!!!!', $(this), $(this).attr('data-edit'))

//   })
// }

$(document).ready(function() {

  $('body').on('click', 'li.text .setting-block span.current-setting', function(e) {
    if ($(this).data('edit')) {
      cc.push('flex_bar:form:click', {model: "settings", field_name: $(this).attr('data-edit')})
        .receive("ok", resp => {
          console.log('got response', resp)
          $(this).parent().html(resp.html)
          $('input.editing').select()
        })
    }
  })
  $('body').on('click', '.setting-block button.cancel', function(e) {
    let name = $(this).parent().prev().attr('name')
    let value = $(this).parent().prev().val()
    cc.push('flex_bar:form:cancel', {model: "settings", field_name: name})
      .receive("ok", resp => {
        console.log('got response', resp)
        $(this).parent().parent().html(resp.html)
      })
  })
  $('body').on('click', '.setting-block button.save', function(e) {
    let name = $(this).parent().prev().attr('name')
    let value = $(this).parent().prev().val()
    cc.push('flex_bar:form:save', {model: "settings", field_name: name, value: value})
      .receive("ok", resp => {
        console.log('got response', resp)
        $(this).parent().parent().html(resp.html)
        toastr.success('Room ' + name + ' updated successfully.')
      })
      .receive("error", resp => {
        console.info('got an error', resp)
        toastr.error(resp.error)
      })
  })
  $('body').on('change', '[type="checkbox"]', function(e, t) {
    console.log('checkbox change t', $(this))
    let name = $(this).attr('name')
    let value = $(this).attr('value')
    if (!value) { value = "false" }
    // if (value == 'on') { value = true } else { value = false }
    start_loading_animation($(this))
    // setTimeout(stop_loading_animation, 2000, $(this))
    cc.push('flex_bar:form:save', {model: "settings", field_name: name, value: value})
    .receive("ok", resp => {
      stop_loading_animation()
        toastr.success('Room ' + name + ' updated successfully.')
    })
  })
})

function start_loading_animation(elem) {
  console.log('start_loading_animation', elem)
  utils.page_loading()
  elem.next().after(utils.loading_animation())
}

function stop_loading_animation(elem) {
  console.log('stop_loading_animation', elem)
  utils.remove_page_loading()
  $('.loading-animation').remove()
}
