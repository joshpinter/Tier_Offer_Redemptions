select				
sls.trn_sls_dte,				
case when sales between 0 and 29.99 then '0-29.99'							
when sales between 30 and 49.99 then '30-49.99'				
when sales between 50 and 74.99 then '50-74.99'				
when sales between 75 and 99.99 then '75-99.99'			
else 'over 100' end as sales_type, 				
count(distinct cast(sls.trn_sls_dte as char(8))||cast(sls.trn_strt_tm as char(10))||sls.trn_nbr||sls.pos_rgst_id||sls.ei_str_id||sls.sls_corr_seq_nbr) as trans,				
sum(sls.units) as units_sold,				
sum(sls.sales) as net_sales_on_redemption				
				
from				
				
(select  b.loc_id, b.ei_loc_id,max(case when a.str_clustr_typ_cde=2000 then str_clustr_nm else null end) as metro,max(case when a.str_clustr_typ_cde=4000 then str_clustr_nm else null end) as ad_version, max(case when a.str_clustr_typ_cde=8000 then str_clustr_nm else null end) as geo_region				
from  eipdb_slv.eiv_c_str_clustr_dim a, eipdb_slv.eiv_c_loc_dim b				
where a.str_clustr_typ_cde in (2000, 4000,8000)				
and a.ei_str_id=b.ei_loc_id				
group by b.loc_id, b.ei_loc_id) str_dim,				
				
 (select a.trn_sls_dte,a.trn_strt_tm,a.trn_nbr,a.pos_rgst_id,a.ei_str_id,a.sls_corr_seq_nbr,sum(sld_qty) as units,sum(net_chrgd_amt) as sales				
 from eipdb_slv.EIV_SLS_TRN_sku_agg a				
 where a.trn_sls_dte between   '2016-02-04' and '2016-02-07'				
 and trn_typ_cde in ('01','02')				
group by a.trn_sls_dte,a.trn_strt_tm,a.trn_nbr,a.pos_rgst_id,a.ei_str_id,a.sls_corr_seq_nbr) as sls,				
				
 (select distinct a.trn_sls_dte,a.trn_strt_tm,a.trn_nbr,a.pos_rgst_id,a.ei_str_id,a.sls_corr_seq_nbr,substr(a.cpn_nbr,1,5) as offerid				
 from eipdb_v.EIV_CUST_INCTV_li_trn_disc a				
 where  a.TRN_SLS_DTE between  '2016-02-04' and '2016-02-07'				
and	substr(a.cpn_nbr,1,5) in ('89922',	'89830',	'89494',	'89493',	'89492',	'89491',	'89490',	'89489',	'89488',	'89484',	'89321',	'89300',	'89280',	'89279',	'89266'
)) promo			
				
where	promo.trn_sls_dte=sls.trn_sls_dte 			
and promo.trn_nbr=sls.trn_nbr				
and promo.pos_rgst_id=sls.pos_rgst_id				
and promo.trn_strt_tm=sls.trn_strt_tm				
and promo.ei_str_id=sls.ei_str_id				
and promo.sls_corr_seq_nbr=sls.sls_corr_seq_nbr				
and promo.ei_str_id=str_dim.ei_loc_id				
group by 1,2	