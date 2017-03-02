var client = deepstream('wss://xxx.deepstreamhub.com?apiKey=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx')

Vue.component('order-item', {
  props: ['order'],
  data: function() {
    this.data = {
        type: '',
        stage: '',
        imageUrl: '',
        states: ['received', 'in-progress', 'ready', 'delivered'],
        currentState: 0
    }
    return this.data
  },
  created: function() {
    this.record = client.record.getRecord(this.order)
    this.record.subscribe((data) => {
      Vue.set(this.data, 'currentState', this.states.indexOf(data.stage))
      Vue.set(this.data, 'type', data.type)
      Vue.set(this.data, 'imageUrl', 'images/' + data.type + '.png')
      Vue.set(this.data, 'stage', data.stage)
    })
  },
  destroyed: function() {
    this.record.discard()
  },
  methods: {
    transition: function(stage) {
      this.record.set('stage', stage)
    }
  }
})

var app = new Vue({
  el: '#app',
  data: {
    loading: true,
    orders: []
  }
})

client.login({}, function(success) {
    if (success) {
        var ordersList = client.record.getList('orders')
        ordersList.subscribe(function(entries) {
            app.$data.orders = entries
        })
    }
})
