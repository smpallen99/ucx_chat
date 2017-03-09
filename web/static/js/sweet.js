import sweetAlert from "./sweetalert.min"

export function warning(text, confirm_text, confirm_callback) {
  sweetAlert({
    title: gettext.are_you_sure,
    text: text,
    type: "warning",
    showCancelButton: true,
    confirmButtonColor: "#DD6B55",
    confirmButtonText: confirm_text,
    closeOnConfirm: false
  },
  confirm_callback)
}
export function warning_confirmation(title, text, timer) {
  swal({
      title: title,
      text: text,
      type: 'success',
      timer: timer,
      showConfirmButton: false,
  })
}
