reqs = do ->
  links = 
    $('.detailedTable-transactionItem')
    .map (idx, el) -> $(el).attr('data-href')
    .toArray()
  ids = _.map links, (link) -> _.last(link.split('/'))
  _.map ids, (id) ->
    Promise.resolve($.get "https://www.paypal.com/myaccount/transaction/details/#{id}", {}, null, 'json')

Promise.all(reqs).then (results) ->
  console.info 'results', _.pluck results, 'data.details'
