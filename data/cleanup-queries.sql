delete from OrderItems where OrderID in (
    select OrderId from Orders where CustomerId = 13
)

delete from Orders where CustomerId = 13