module MainHelper
    def select_report
        options = [['Daily Cash Summary', 'Daily Cash'],
                   ['Cashier Summary', 'Cashier'],
                   ['Income Summary', 'Income'],
                   ['Census Report','Census']
    ]
    return options
  end
end
