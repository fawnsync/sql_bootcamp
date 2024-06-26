WITH last_rate_cte AS (SELECT currency.id                      AS currency_id,
                              currency.name                    AS currency_name,
                              (SELECT rate_to_usd
                               FROM currency
                               WHERE currency.updated = (SELECT MAX(updated)
                                                         FROM currency)
                                 AND id = balance.currency_id) AS last_rate
                       FROM currency
                                INNER JOIN balance ON currency.id = balance.currency_id
                       GROUP BY currency.id, currency.name, balance.currency_id)

SELECT COALESCE("user".name, 'not defined')                                   AS user_name,
       COALESCE("user".lastname, 'not defined')                               AS user_lastname,
       balance.type,
       SUM(COALESCE(balance.money, 1))                                        AS volume,
       COALESCE(last_rate_cte.currency_name, 'not defined')                   AS currency_name,
       COALESCE(last_rate_cte.last_rate, 1)                                   AS last_rate_to_usd,
       SUM(COALESCE(balance.money, 1)) * COALESCE(last_rate_cte.last_rate, 1) AS total_volume_in_usd
FROM balance
         LEFT JOIN "user" ON "user".id = balance.user_id
         LEFT JOIN last_rate_cte ON balance.currency_id = last_rate_cte.currency_id
GROUP BY balance.type,
         "user".id,
         "user".name,
         "user".lastname,
         last_rate_cte.currency_name,
         last_rate_cte.last_rate
ORDER BY user_name DESC, user_lastname, balance.type;
