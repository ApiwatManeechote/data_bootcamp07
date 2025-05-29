-- For higher manager, if we would like to analyze the sales performance of each Sales Support Agent in our team, then this will work!

SELECT
    e.EmployeeId,
    e.FirstName || ' ' || e.LastName AS agent_name,
    SUM(i.Total) AS total_sales
FROM employees e
JOIN customers c ON e.EmployeeId = c.SupportRepId
JOIN invoices i ON c.CustomerId = i.CustomerId
WHERE e.Title = 'Sales Support Agent'
GROUP BY e.EmployeeId, agent_name
ORDER BY total_sales DESC;

-- In case if we are about to discuss about the low-performance Sales Support Agents with their supervisor, then we can use self-join like this to find their higher hierarchy employee.

SELECT
    e.FirstName AS employee_firstname,
    e.LastName AS employee_lastname,
    e2.FirstName || ' ' || e2.LastName AS direct_report_to
FROM employees AS e
LEFT JOIN employees AS e2 ON e.ReportsTo = e2.EmployeeId;
