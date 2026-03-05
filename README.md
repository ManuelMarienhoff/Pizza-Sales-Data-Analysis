# Pizza Sales Analysis: Commercial and Operational Optimization

## 1. Background and Overview
A pizzeria has a detailed historical sales record for the period from January to December 2015. Despite capturing granular information on each order, product, and price, the company lacked a structured analysis that would allow it to understand demand patterns, actual menu performance, and operational improvement opportunities.

Historically, decisions regarding the menu, promotions, and staff allocation have been made empirically, without prioritizing schedules or products with the greatest impact on revenue.

**Project Objective:** Transform raw transactional data into actionable insights using SQL and data visualization, providing management with a tool to make informed decisions regarding menu optimization, marketing strategies, and operational efficiency.

The analysis seeks to answer, among others, the following key business questions:
* What are the key sales trends across different days, weeks, and hours?
* Which pizza categories and sizes generate the highest volume and revenue?
* Which specific products are the primary drivers of revenue?
* Are there underperforming products or rare ingredients causing inventory inefficiencies (capital leakage)?
* What is the Average Order Value (AOV), and how many pizzas are sold per order on average?
* How does customer purchasing behavior differ between weekdays and weekends?

The interactive [Tableau dashboard](https://public.tableau.com/app/profile/manuel.marienhoff/viz/PizzaSalesReport_17727340650500/HOMEDB) is available for online exploration and download

You can view the [complete SQL analysis script] used to extract, analyze, and prepare the data for Tableau
---

## 2. Data Structure Overview
The analysis was based on a consolidated transactional dataset (`pizza_sales.csv`) structured as a single flat table that records each order line at a granular level with a total of 48620 rows.

To facilitate understanding and subsequent SQL analysis, the data structure is logically categorized as follows:
* **Identifiers:** `order_id`, `pizza_id`, `pizza_name_id`.
* **Transactional Metrics:** `quantity`, `unit_price`, `total_price`.
* **Temporal Dimensions:** `order_date`, `order_time`.
* **Product Dimensions:** `pizza_size`, `pizza_category`, `pizza_name`, `pizza_ingredients`.

---

## 3. Executive Summary: Overview of Findings
The commercial performance of the pizzeria during 2015 reveals a business with a consistent volume averaging 935 sales per week, driven by a bimodal demand model featuring highly profitable, high-ticket corporate lunches on weekdays and a sharp shift toward nighttime sales on weekends. By isolating the price effect from volume, the analysis uncovered critical operational inefficiencies, specifically capital leakage tied to zero-turnover items with exclusive ingredients (e.g., *The Brie Carre Pizza*) and logistical friction from marginal XL/XXL formats. These findings present immediate opportunities to streamline the supply chain, boost the Average Order Value (AOV) through targeted cross-selling on the dominant 'Large' size, and optimize staff allocation to maximize overall profitability.

Below is the overview page from the Tableau dashboard and more examples are included throughout the report. The entire interactive dashboard can be visited [here](https://public.tableau.com/app/profile/manuel.marienhoff/viz/PizzaSalesReport_17727340650500/HOMEDB).

<img width="1300" height="300" alt="image" src="https://github.com/user-attachments/assets/d0463dc5-25ed-408f-b8b8-41ec504df744" />





---

## 4. Insights Deep Dive
By cross-referencing temporal and transactional variables in SQL, we identified key patterns in customer behavior and operational anomalies that directly impact the business:

### A. Macro Trends (Weekly & Daily)
* **Seasonality and Anomalies:** Weekly volume peaks in **Week 48** (1,186 pizzas sold). Conversely, **Week 39** recorded the historical minimum (674 pizzas), highlighting a total absence of sales on Thursday and Friday. Given that these are typically high-revenue days, we infer an operational anomaly (e.g., store closure due to maintenance or force majeure).
* **Daily Performance:** The days with the highest sales volume are **Friday, Saturday, and Thursday** (in that order). Sunday shows the lowest performance of the entire week.
<img width="500" height="300" alt="image" src="https://github.com/user-attachments/assets/9945dea0-5624-433a-8bad-695415f796a2" />
<img width="500" height="300" alt="image" src="https://github.com/user-attachments/assets/f734c7b8-eede-4c3c-8744-9ca76e75f755" />


### B. General Behavior by Time Slot
The business operates heavily under a bimodal model, but with a clear dominance in midday intensity:
* **Lunch (12:00 PM - 1:59 PM - Main Peak):** This is the time of highest traffic and sales intensity for the store. It generated $217.8K in revenue (13.2K pizzas across 5K orders). Purchasing behavior is highly profitable: the **Average Order Value (AOV) is high ($43.81)**, with an average of **3 pizzas per order**. This suggests a strong component of corporate purchases or large groups.
* **Dinner (5:00 PM - 7:59 PM - Secondary Peak):** Although it covers a broader time slot, the traffic intensity per hour is lower than at lunch. It generated $248K in revenue (15K pizzas across 6.7K orders). The purchasing profile changes drastically: the nighttime customer spends less, with an **AOV of $36.80** and smaller carts of **2 pizzas per order** (individual or couples' purchases).

<img width="1200" height="350" alt="image" src="https://github.com/user-attachments/assets/d255e765-0720-48b2-84db-cbd78198b605" />


### C. Weekday vs. Weekend (Business Rotation)
By segmenting peak hours by day type, we discovered that the main source of revenue rotates depending on the day of the week:
* **The shift in Revenue weight:** From Monday to Friday, the business maintains a perfect balance between its two peaks; lunch contributes **29.09%** of daily sales and dinner **29.28%**. However, on weekends, behavior shifts toward the night: lunch drops to **20.12%**, while dinner jumps to account for **33.20%** of daily revenue.
* **Ticket Elasticity (AOV):** The "high-value lunch / lower-value dinner" rule is a structural constant of the business. Lunches consistently drive higher tickets, reaching an AOV of **$46.95** on weekends (vs. $43.06 on weekdays). Dinners, on the other hand, remain inelastic at **~$36.70** regardless of the day.

*The following table summarizes the SQL query output that substantiates these trends, providing a clear breakdown of revenue distribution, average order value, and cart size across shifts:*
<img width="1000" height="300" alt="image" src="https://github.com/user-attachments/assets/675e918e-3355-4803-b08b-93c46d2e77f7" />

### D. Menu Efficiency and Supply Chain Audit
By conducting a *bottom-up* analysis separating the price effect from volume, ingredient utilization was audited to detect inventory inefficiencies. The most critical case detected is **"The Brie Carre Pizza"**:
* **Commercial Performance:** It is the pizza with the highest Average Unit Price on the entire menu ($23.65), but it is the least sold product of the entire year (only 490 units).
* **Capital Leakage (Exclusive Ingredients):** A recipe-level breakdown revealed that 5 of its 6 ingredients (*Brie Carre Cheese, Caramelized Onions, Pears, Prosciutto, and Thyme*) are **100% exclusive** to this pizza and are not shared with any other menu option.
* **Other Exclusivities:** While there are other unique ingredients on the menu (e.g., *Plum Tomatoes* or *Soppressata Salami*), these belong to pizzas with an acceptable turnover (over 900 units annually), temporarily justifying their place in inventory.

*The data tables below validate this inefficiency, illustrating the stark contrast between The Brie Carre's high price and low volume, alongside the SQL breakdown confirming its exclusive inventory:*

<img width="500" height="300" alt="image" src="https://github.com/user-attachments/assets/0d6814ae-2a67-4896-a70d-feba1791d683" />
<img width="500" height="300" alt="image" src="https://github.com/user-attachments/assets/63cb39d8-ab55-4654-ad45-5c69a819ace6" />



### E. Performance by Format (Pizza Size)
Analyzing the *Product Mix* by pizza size shows a strong polarization in consumer preferences:
* **The anchor of the business:** The **'Large' (L)** size unquestionably dominates sales volume and revenue, establishing itself as the standard or default option in the customer's mind.
* **Inefficient formats:** At the opposite end, extra-large formats (**'XL' and 'XXL'**) have a marginal and statistically insignificant market share compared to the rest of the sizes.

 <img width="500" height="300" alt="image" src="https://github.com/user-attachments/assets/d6315030-ccda-4105-b74f-e89db0e59356" />


---

## 5. Recommendations
Based on the data findings, the following strategic and operational actions are suggested:

1. **Menu Rationalization (Quick Win):** Immediately eliminate *"The Brie Carre Pizza"* from the menu. Dropping this zero-turnover product removes the need to purchase and store 5 exclusive and expensive ingredients. This will simplify the supply chain, drastically reduce food waste, and free up working capital without negatively affecting Total Revenue.
2. **Format Rationalization (Operational Simplification):** It is recommended to eliminate the XL and XXL formats. Although they share the recipe with standard sizes, they generate hidden logistical costs (oversized packaging) and a lack of standardization in the kitchen. Demand for these sizes can be redirected to combinations of standard formats (e.g., 1 Large + 1 Medium).
3. **Upselling Strategy on the 'Large' Format:** Given that the 'Large' pizza is the product with the most natural traction, it should be used to increase the Average Order Value (AOV), especially during dinner. It is suggested to implement cross-selling promotions (e.g., "Add a Small pizza to your Large order for X% off"), incentivizing the nighttime cart to grow from 2 to 3 items.
4. **Segmented Marketing Strategies:** Promotions should not be generic. It is recommended to offer "Executive or Group Combos" during weekday lunches to capitalize on the organic demand of 3 pizzas per order, and to launch "Couple Combos" tailored for dinner and weekends.
5. **Operational Efficiency and Staffing Alignment:** It is recommended to coordinate with Operations/HR to ensure maximum staffing during the highest intensity hour (lunch from Monday to Friday, 12:00 PM - 2:00 PM) and strategically shift that capacity to night shifts during weekends. This will prevent service bottlenecks and reduce labor costs during off-peak hours.
6. **Profitability and Cost Analysis (Next Steps):** Align with the Purchasing/Supplier team to integrate the **Cost of Goods Sold (COGS)** per ingredient. This will allow transforming this sales analysis into a **Profit Margin Analysis**, evaluating whether pizzas using exclusive mid-turnover ingredients are truly profitable or if their operational costs outweigh their benefit.
