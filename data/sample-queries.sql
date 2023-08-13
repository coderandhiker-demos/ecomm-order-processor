SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Email,
    COUNT(o.OrderID) AS OrderCount,
    ISNULL(SUM(oi.Quantity), 0) AS TotalItemsOrdered,
    MAX(o.OrderDate) AS MostRecentOrderDate
FROM
    Customers c
LEFT JOIN
    Orders o ON c.CustomerID = o.CustomerID
LEFT JOIN
    OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Email
ORDER BY
    c.CustomerID,
    c.LastName,
    c.FirstName;



SELECT
    c.FirstName,
    c.LastName,
    p.ProductName,
    p.Price
FROM
    Customers c
JOIN
    Orders o ON c.CustomerID = o.CustomerID
JOIN
    OrderItems oi ON o.OrderID = oi.OrderID
JOIN
    Products p ON oi.ProductID = p.ProductID
WHERE
    c.CustomerID = 13
ORDER BY
    c.FirstName,
    c.LastName,
    p.ProductName;
