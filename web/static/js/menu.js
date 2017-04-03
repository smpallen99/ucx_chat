
class Menu {
  constructor() {
    this.register_events()
  }

  is_open() {
    return $('.main-content').offset().left != 0
  }

  setup() {
    if ($('.burger').is(':visible')) {
      if (this.is_open()) {
        this.open()
      } else {
        this.close()
      }
    }
  }
  open() {
    $('.main-content').css('transform', `translateX(260px)`)
    $('.burger').addClass('menu-opened')
  }
  close() {
    $('.main-content').css('transform', `translateX(0px)`)
    $('.burger').removeClass('menu-opened')
  }

  register_events() {
    $('body').on('click', '.burger', e => {
      if (this.is_open()) {
        this.close()
      } else {
        this.open()
      }
    })
  }
}

export default Menu
