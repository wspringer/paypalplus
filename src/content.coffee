getTransactions = ->
  Promise.all(
    do ->
      links =
        $('.detailedTable-transactionItem')
        .map (idx, el) -> $(el).attr('data-href')
        .toArray()
      ids = _.map links, (link) -> _.last(link.split('/'))
      _.map ids, (id) ->
        Promise.resolve($.get "https://www.paypal.com/myaccount/transaction/details/#{id}", {}, null, 'json')
  )

downloadAllBtn = $.parseHTML '''
<button
  class="vx_btn vx_btn-secondary vx_btn-small"
  style="margin-left:15px">Xero CSV</button>
'''

fixAmount = (amount) ->
  fixed = amount.replace(',', '.')
  fixed.substr(0, fixed.length - 4)

fixDate = (date) -> moment(date, 'D MMMM YYYY').format('DD/MM/YY')

$(downloadAllBtn)
.click (evt) ->
  evt.preventDefault()
  getTransactions()
  .then (transactions) ->
    console.info 'Transactions', transactions
    all = _.map transactions, (transaction) ->
      [
        fixDate(_.get transaction, 'data.details.date')
        fixAmount(_.get transaction, 'data.details.fundingSource.fundingSourceList[0].amount')
        _.get transaction, 'data.details.counterparty.name'
        _.pluck(_.get(transaction, 'data.details.itemDetails.itemList'), 'name').join(', ')
        _.get transaction, 'data.details.transactionId'
        do ->
          source = _.get transaction, 'data.details.fundingSource.fundingSourceList[0]'
          "#{source.institution} #{source.accountType} x-#{source.last4}"
      ]
    encoded = new CSV(all, header: [ "Date", "Amount", "Payee", "Description", "Reference", "Account" ]).encode()
    blob = new Blob([encoded], type: "text/plain;charset=utf-8")
    saveAs(blob, 'transactions.csv', true)


$('input[name=filterSubmit]')
.after(downloadAllBtn)


