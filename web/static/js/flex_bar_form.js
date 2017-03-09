import * as cc from "./chat_channel"
import toastr from 'toastr'
import sweetAlert from "./sweetalert.min"
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
      cc.get('/room_settings/' + $(this).attr('data-edit'), {model: "settings"})
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
    cc.get('/room_settings/' + name + '/cancel', {model: "settings"})
      .receive("ok", resp => {
        console.log('got response', resp)
        $(this).parent().parent().html(resp.html)
      })
  })
  $('body').on('click', '.setting-block button.save', function(e) {
    let name = $(this).parent().prev().attr('name')
    let value = $(this).parent().prev().val()
    cc.put('/room_settings/' + name, {model: "settings", value: value})
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
  $('body').on('change', '.channel-settings [type="checkbox"]', function(e, t) {
    console.log('checkbox change t', $(this))
    let name = $(this).attr('name')
    let value = $(this).is(':checked')
    if (!value) { value = "false" }
    // if (value == 'on') { value = true } else { value = false }
    start_loading_animation($(this))
    // setTimeout(stop_loading_animation, 2000, $(this))
    cc.put('/room_settings/' + name, {model: "settings", value: value})
    .receive("ok", resp => {
      stop_loading_animation()
        toastr.success('Room ' + name + ' updated successfully.')
    })
  })
  $('body').on('click', '.channel-settings nav button.delete', function(e) {
    sweetAlert({
      title: gettext.are_you_sure,
      text: gettext.deleting_room_cannot_undone,
      type: "warning",
      showCancelButton: true,
      confirmButtonColor: "#DD6B55",
      confirmButtonText: gettext.yes_delete_it,
      closeOnConfirm: false
    },
    function(){
      cc.delete_('/room/' + ucxchat.room)
        .receive("ok", resp => {
          if (resp.success) {
            toastr.success(resp.success)
          }
          swal({
              title: gettext.deleted,
              text: gettext.the_room_has_be_deleted,
              type: 'success',
              timer: 1000,
              showConfirmButton: false,
          })
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
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
