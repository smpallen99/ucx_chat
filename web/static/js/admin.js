import toastr from 'toastr'

class Admin {
  constructor() {
    this.modifed = false
    this.register_events()
  }

  register_events() {
    $('body').on('change', '.admin-settings form', function(e) {
      $('button.save[disabled="true"]').removeAttr('disabled')
    })
    $('body').on('change', '.permissions-manager [type="checkbox"]', function(e, t) {
      e.preventDefault()
      console.log('checkbox change t', $(this))
      let name = $(this).attr('name')
      let value = $(this).is(':checked')

      if (!value) { value = "false" }
      clientchan.push('admin:permissions:change:' + name, {value: value})
      .receive("ok", resp => {
        // stop_loading_animation()
        toastr.success('Room ' + name + ' updated successfully.')
      })
    })
    $('body').on('click', '.page-settings .section button.expand', function(e) {
      e.preventDefault()
      $(this)
        .addClass('collapse')
        .removeClass('expand')
        .first().html('Collapse')
        .closest('.section-collapsed')
        .removeClass('section-collapsed')
    })
    $('body').on('click', '.page-settings .section button.collapse', function(e) {
      e.preventDefault()
      $(this)
        .removeClass('collapse')
        .addClass('expand')
        .first().html('Expand')
        .closest('.section-title')
        .parent()
        .addClass('section-collapsed')
    })
    $('body').on('click', '.admin-settings button.save', function(e) {
      console.log('saving form....', $('form').data('id'))
      e.preventDefault()
      clientchan.push('admin:save:' + $('form').data('id'), $('form').serializeArray())
        .receive("ok", resp => {
          if (resp.success) {
            $(this).attr('disabled', 'true')
            this.modified = false
            toastr.success(resp.success)
          } else if (resp.error) {
            toastr.error(resp.error)
          }
      })
    })


  }
}

export default Admin
