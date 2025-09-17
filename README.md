# 🌾 EER Diagram – Agronegócio (MySQL)

## 📌 Sobre o Projeto

Este projeto apresenta uma **modelagem de dados (EER Diagram) para o setor do agronegócio**, desenvolvida em **MySQL**.
O objetivo é fornecer uma estrutura robusta para **análise de dados agrícolas e comerciais**, permitindo a integração entre **produção, estoque, contratos e finanças**.

A modelagem foi pensada para suportar indicadores estratégicos como:

* **Produtividade agrícola (t/ha)**
* **Custos por talhão e safra**
* **Controle de estoque (insumos e commodities)**
* **Execução de contratos de compra e venda**
* **Margem bruta por safra**

---

## 🗂 Estrutura do Banco (10 Tabelas)

1. **farms** – Cadastro de fazendas
2. **fields** – Talhões (campos) vinculados às fazendas
3. **seasons** – Safras (ex.: 2025/2026)
4. **crops** – Culturas (soja, milho, café, etc.)
5. **plantings** – Plantios (vincula talhão + safra + cultura)
6. **harvests** – Colheitas (quantidade, qualidade, umidade)
7. **products** – Produtos (insumos e commodities)
8. **counterparties** – Parceiros (fornecedores, compradores, transportadoras)
9. **contracts** – Contratos de compra e venda
10. **stock\_movements** – Movimentações de estoque (entrada, saída, consumo, colheita)

---

## 🔗 Relacionamentos Principais

* **Uma fazenda** → **vários talhões**
* **Uma safra** → **vários plantios**
* **Uma cultura** → **vários plantios**
* **Um plantio** → **múltiplas colheitas**
* **Contratos** vinculados a **parceiros** e **produtos**
* **Movimentações de estoque** registrando **entradas e saídas** (compra, venda, consumo no campo, colheita)

---

## ⚙️ Como Utilizar

1. Clone este repositório:

   ```bash
   git clone https://github.com/KelvenPer/Projeto-Agronegocios
   ```
2. Acesse a pasta do projeto:

   ```bash
   cd Projeto-Agronegocios
   ```
3. Importe o arquivo `.sql` no seu MySQL Workbench ou rode no terminal:

   ```bash
   mysql -u usuario -p < agronegocio_eer.sql
   ```

---

## 📊 Exemplos de Queries

### 1. Produtividade (t/ha) por talhão e safra

```sql
SELECT
  f.name AS farm,
  fi.code AS field,
  s.name AS season,
  SUM(h.quantity_t) / SUM(fi.area_ha) AS yield_t_per_ha
FROM harvests h
JOIN plantings p ON p.planting_id = h.planting_id
JOIN fields fi ON fi.field_id = p.field_id
JOIN farms f ON f.farm_id = fi.farm_id
JOIN seasons s ON s.season_id = p.season_id
GROUP BY f.name, fi.code, s.name;
```

### 2. Custo de insumos por plantio (R\$/ha)

```sql
SELECT
  p.planting_id,
  f.name AS farm,
  fi.code AS field,
  s.name AS season,
  SUM(sm.quantity * sm.unit_price) / NULLIF(fi.area_ha,0) AS input_cost_per_ha
FROM stock_movements sm
JOIN products pr ON pr.product_id = sm.product_id AND pr.category = 'INPUT'
JOIN plantings p ON p.planting_id = sm.planting_id
JOIN fields fi ON fi.field_id = p.field_id
JOIN farms f ON f.farm_id = fi.farm_id
JOIN seasons s ON s.season_id = p.season_id
WHERE sm.movement_type = 'CONSUMPTION'
GROUP BY p.planting_id, f.name, fi.code, s.name;
```

### 3. Execução de contratos (entregue vs. contratado)

```sql
SELECT
  c.contract_id,
  cp.name AS counterparty,
  c.type,
  pr.name AS product,
  c.quantity_agreed,
  SUM(CASE WHEN c.type='SALE' AND sm.movement_type='SALE' THEN sm.quantity
           WHEN c.type='PURCHASE' AND sm.movement_type='PURCHASE' THEN sm.quantity
           ELSE 0 END) AS delivered_qty
FROM contracts c
JOIN counterparties cp ON cp.counterparty_id = c.counterparty_id
JOIN products pr ON pr.product_id = c.product_id
LEFT JOIN stock_movements sm ON sm.contract_id = c.contract_id
GROUP BY c.contract_id, cp.name, c.type, pr.name, c.quantity_agreed;
```

---

## 📈 Aplicações Possíveis

* Dashboards em **Power BI** ou **Tableau**
* Relatórios de **gestão agrícola e comercial**
* Integração com sistemas de **ERP e IoT no campo**
* Base para **modelos de previsão de safra**

---

## 📥 Download

📂 Arquivo `.sql` completo disponível neste repositório.

👉 [Clique aqui para acessar o repositório no GitHub](https://github.com/KelvenPer/Projeto-Agronegocios)
