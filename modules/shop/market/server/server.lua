ESX.RegisterServerCallback("haveMoneyAndPay", function(src, cb, price, Panier)
    local xPlayer = ESX.GetPlayerFromId(src)
    local money = xPlayer.accounts[3].money
    print(json.encode(xPlayer.accounts))
    print(money)
    if money >= price then
        for k,v in pairs(Panier) do
            xPlayer.addInventoryItem(v.db_name, v.amount)
        end
        xPlayer.removeMoney(price)
        cb(true)
    else
        cb(false)
    end
end)