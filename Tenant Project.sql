####Q1
SELECT P.profile_id, P.email_id, P.phone, Concat(P.first_name,' ',last_name) as FullName
FROM dbo.[Tenancy History] H join dbo.Profiles P on H.profile_id = P.profile_id
WHERE DATEDIFF(day, H.move_in_date, H.move_out_date) = (
    SELECT MAX(DATEDIFF(day, move_in_date, move_out_date))
    FROM dbo.[Tenancy History]
);

#### Q2
Select P.email_id, P.phone, Concat(P.first_name,' ',last_name) as FullName, H.rent
From dbo.Profiles P join dbo.[Tenancy History] H on P.profile_id = H.profile_id
Where marital_status = 'Y' and rent > 9000;

###Q3
SELECT
    P.profile_id,
    P.email_id,
    P.phone,
    CONCAT(P.first_name, ' ', P.last_name) AS FullName,
    TH.house_id,
    TH.move_in_date,
    TH.move_out_date,
    TH.rent,
    A.city,
    E.latest_employer,
    E.occupational_category,
    COUNT(R.id) AS TotalReferral
FROM
    dbo.Profiles P
JOIN
    dbo.[Tenancy History] TH ON P.profile_id = TH.profile_id
JOIN
    dbo.Addresses A ON A.house_id = TH.house_id
LEFT JOIN
    dbo.Referral R ON R.profile_id = P.profile_id
JOIN
    dbo.Employee_Status E ON E.profile_id = P.profile_id
WHERE
    (A.city IN ('Pune', 'Bangalore')) 
    AND TH.move_in_date >= '2015-01-01' 
    AND TH.move_in_date <= '2016-01-31'
GROUP BY
    P.profile_id,
    P.email_id,
    P.phone,
    CONCAT(P.first_name, ' ', P.last_name),
    TH.house_id,
    TH.move_in_date,
    TH.move_out_date,
    TH.rent,
    A.city,
    E.latest_employer,
    E.occupational_category
Order By TH.rent DESC;

####Q4
SELECT
    CONCAT(P.first_name, ' ', P.last_name) AS full_name,
    P.email_id,
    P.phone,
    P.referral_code,
    COUNT(R.id) AS total_referrals,
    SUM(CASE WHEN R.referral_valid = 1 THEN R.referrer_bonus_amount ELSE 0 END) AS total_bonus_amount
FROM
    dbo.Profiles P
JOIN
    dbo.Referral R ON P.profile_id = R.profile_id
GROUP BY
    P.profile_id, P.first_name, P.last_name, P.email_id, P.phone, P.referral_code
HAVING
    COUNT(R.id) > 1;

####Q5
SELECT
    A.city,
    SUM(TH.rent) AS total_rent_per_city
FROM
    dbo.[Tenancy History] TH
JOIN
    dbo.Addresses A ON TH.house_id = A.house_id
GROUP BY
    A.city
WITH ROLLUP;
SELECT
    'Grand Total' AS city,
    SUM(TH.rent) AS total_rent_all_cities
FROM
    dbo.[Tenancy History] TH;

####Q6
CREATE VIEW vw_tenant AS
SELECT
    TH.profile_id,
    TH.rent,
    TH.move_in_date,
    H.house_type,
    H.beds_vacant,
    A.description,
    A.city
FROM
    dbo.[Tenancy History] TH
JOIN
    dbo.Houses H ON TH.house_id = H.house_id
JOIN
    dbo.Addresses A ON H.house_id = A.house_id
WHERE
    TH.move_in_date >= '2015-04-30'
    AND H.beds_vacant > 0;

####Q7
UPDATE Referral
SET valid_till = DATEADD(MONTH, 1, valid_till)
WHERE ID IN (
    SELECT ID
    FROM Referral
    GROUP BY ID
    HAVING COUNT(ID) > 1
);

####Q8
SELECT
    P.profile_id,
    CONCAT(P.first_name, ' ', P.last_name) AS full_name,
    P.phone,
    CASE
        WHEN TH.rent > 10000 THEN 'Grade A'
        WHEN TH.rent BETWEEN 7500 AND 10000 THEN 'Grade B'
        ELSE 'Grade C'
    END AS 'Customer Segment'
FROM
    dbo.Profiles P
JOIN
    dbo.[Tenancy History] TH ON P.profile_id = TH.profile_id;


#### Q9
SELECT TOP 1
    H.*
FROM
    dbo.Houses H
JOIN
    (
        SELECT
            house_id,
            COUNT(profile_id) AS occupancy
        FROM
            dbo.[Tenancy History]
        GROUP BY
            house_id
    ) TH ON H.house_id = TH.house_id
ORDER BY
    TH.occupancy DESC;

