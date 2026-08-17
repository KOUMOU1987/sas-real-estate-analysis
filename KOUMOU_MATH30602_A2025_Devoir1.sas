*****************************************************************************************************;
*****************************************************************************************************;
*                             Math30602 Logiciels statistiques en gestion                           *;
*                                             Devoir 1                                              *;
*                                  Réalisé par KOUMOU Nettey Assion                                 *;
*                                        Matricule 11371339                                         *;

*****************************************************************************************************;
*****************************************************************************************************;
*                                            DONNÉES                                                *;

*****************************************************************************************************;
*                                         question 1
                           Création de deux librairies input et output                              *;
*                                                                                                   *;
*****************************************************************************************************;

libname input "C:\Users\Yvanm\Documents\cours\devoir\input";/*Creation de la librairie input*/

libname output "C:\Users\Yvanm\Documents\cours\devoir\output";/*Creation de la librairie output*/

*****************************************************************************************************;
*                                          question 2                                               *;
*       Importez, dans la librairie input, créée à la question précédente, les 2 fichiers suivants         *; 
*2002-2018-property-sales-data.csv  2022-property-sales-data.xlsx .Vous les nommerez respectivement *; 
*                             Property_2002_2018 et Property_2022                                   *;
*                                                                                                   *;
*****************************************************************************************************;
/*Importer les données csv dans SAS et les stocker dans la librairie input*/

PROC IMPORT OUT= input.Property_2002_2018
DATAFILE= "C:\Users\Yvanm\Documents\cours\devoir\2002-2018-property-sales-data.csv"
DBMS=CSV REPLACE;
GETNAMES=YES;
RUN;

/*Importer les données excel dans SAS et les stocker dans la librairie input*/

PROC IMPORT OUT= input.Property_2022    
DATAFILE= "C:\Users\Yvanm\Documents\cours\devoir\2022-property-sales-data.xlsx"
DBMS=EXCEL REPLACE;
RANGE="2022-property-sales-data$";
GETNAMES=YES;
RUN;

/*CREATIONN DES TABLES DANS work*/
DATA Property_2002_2018;
SET input.Property_2002_2018;
RUN;
DATA Property_2022 ;
SET input.Property_2022 ;
RUN;

*****************************************************************************************************;
*                                         question 3
                 Sortez une description sommaire de la table Property_2002_2018.                              *;
*                                                                                                   *;
*****************************************************************************************************;

/* === Description sommaire de la table Property_2002_2018 === */

proc sql;
select 
count(*) as Nb_lignes,
count(distinct name) as Nb_variables
from dictionary.columns
where libname = "INPUT" and memname = "PROPERTY_2002_2018";
select 
name as Nom_Variable,
type as Type,
length as Longueur,
format as Format,
label as Etiquette
from dictionary.columns
where libname = "INPUT" and memname = "PROPERTY_2002_2018"
order by name;
quit;

proc sql outobs=10;
select*
from input.Property_2002_2018;
quit;

proc sql;
select count(*) as nb_observations
from input.Property_2002_2018;
quit;


*****************************************************************************************************;
*                                            SQL                                            *;

*****************************************************************************************************;
*                                         question 1
*Dans le fichier 2002-2018-property-sales-data, donnez la date de la plus ancienne et de la         *;
*                               plus récente transaction (Sale_date).                               *;
*                                                                                                   *;
*****************************************************************************************************;

/*premiere méthode*/
/*transaction récente*/
proc sql outobs=1;
select sale_date as sale_date_recente
from input.Property_2002_2018
order by sale_date desc;
quit;

/*transaction ancienne*/
proc sql outobs=1;
select sale_date as sale_date_ancienne
from input.Property_2002_2018
order by sale_date asc;
quit;

/*deuxième méthode*/
proc sql;
select 
min(sale_date) as sale_date_ancienne format=date9.,
max(sale_date) as sale_date_recente format=date9.
from input.Property_2002_2018;
quit;

**************************************************************************************************** *;
*                                         question 2                                                 *;
*Dans le fichier 2002-2018-property-sales-data, existe-t-il des propriétés ayant été transigées      *;
*plusieurs fois ? Si une propriété est transigée plusieurs fois, elle devrait apparaître plusieurs   *;
*fois dans le fichier.Sortez la liste de ces propriétés avec toutes leurs caractéristiques           *;
*et exportez le résultat dans la librairie output sous le nom multi_transaction.                     *;                                    *;
*                                                                                                    *;
**************************************************************************************************** *;

/* Identifier les propriétés ayant été  plus d’une transaction */
proc sql;
create table output.multi_transaction_0 as
select taxkey,count(*) as nb_répétition
from input.Property_2002_2018
group by taxkey
having count(*) >1;
quit;

/* ajouter les caractéristiques de ces propriétés identifier */
proc sql;
create table output.multi_transaction as
select A.*,B.nb_répétition
from input.Property_2002_2018 as A
inner join output.multi_transaction_0 as B
on A.taxkey=B.taxkey;
quit;

*****************************************************************************************************;
*                                         question 3                                                *;
*              Combien de propriétés ont été transigées plusieurs fois                              *;
*                                                                                                   *;
*****************************************************************************************************;
proc sql;
select count(*) as nb_propriétés
from output.multi_transaction_0;
quit;

*****************************************************************************************************;
*                                         question 4                                                *;
*Existe-t-il des propriétés vendues en 2022 qui avaient déjà été vendues entre 2002 et 2018 ?Sortir *;
*la liste de ces propriétés.                            *;
*                                                                                                   *;
*****************************************************************************************************;

proc sql;
create table pro_vendus as
select A.*,B.*
from input.Property_2022 as A
inner join input.Property_2002_2018 as B
on A.taxkey=B.taxkey;
quit;

proc sql;
select count(*) as nb_propriétés
from pro_vendus;
quit;

*****************************************************************************************************;
*                                         question 5                                                *;
*Faire la jointure des Property_2002_2018 et Property_2022 et ne garder que les propriétés communes *;
*aux deux tables. Conservez toutes les colonnes de la table Property_2002_2018 mais ne rapportez que *;
*les colonnes de date de vente et prix de vente dela table Property_2022 et ajoutez le suffixe ‘_2022’*;
*aux deux colonnes issues de Property_2022.Enregistrez la table dans la librairie output sous le nom *;
*in_2_files.                           *;
*                                                                                                   *;
*****************************************************************************************************;

proc sql;
create table output.in_2_files as
select A.*,B.sale_date as sale_date_2022,B.sale_price as sale_price_2022
from input.Property_2002_2018 as A
inner join input.Property_2022 as B
on A.taxkey=B.taxkey;
quit;

*****************************************************************************************************;
*                                         question 6                                                *;
*Nous souhaitons extraire de la table créée à la question précédente seulement les lignes           *;
*correspondantes à la première vente et à la dernière vente de chaque propriété.                    *;
*Indice : la ligne qui contient le plus ancienne et la plus récente transaction pour chaque         *;
*propriété correspondra à celle ou sale_date vaut le min de Sale_date et le Sale_date_2022          *;
*sera le max de sale_date_2022.                                                                     *;
*                                                                                                   *;
*****************************************************************************************************;

/* Extraire ancienne et recente vente par propriété */

proc sql;
create table output.old_new_sale as
select 
taxkey,
min(sale_date) as old_sale_date format=date9.,
max(sale_date_2022) as new_sale_date format=date9.
from output.in_2_files
group by taxkey;
quit;

/* ajouter les caractéristiques de ces propriétés identifier */
proc sql;
create table old_new_details as
select A.*
from output.in_2_files as A
inner join output.old_new_sale as B
on A.taxkey=B.taxkey
and(A.sale_date = B.old_sale_date  or  A.sale_date_2022 = B.new_sale_date);
quit;

*****************************************************************************************************;
*                                         question 7                                                *;
*Calculez les taux de croissance du prix de chaque propriété et nommez la nouvelle colonne GR_price *;                                                                *;
*                                                                                                   *;
*****************************************************************************************************;

proc sql;
create table in_2_files_growth as
select*, 
case
when Sale_Price > 0 then
(Sale_Price_2022 - Sale_Price) / Sale_Price
else .
end as GR_price format=percent8.2
from output.in_2_files;
quit;

***********************************************************************************************************;
*                                         question 8                                                      *;
*Dans une seule table de résultat, par année, sortir le nombre de transactions réalisées ainsi            *;
*ue la somme des prix vendus (pour toutes les années de 2002 à 2018 et 2022). Ordonnez le résultat        *;
*par année de vente.Enregistrez le résultat dans la librairie output avec comme nom summary_sales_2002_2022*;                                                                  *;
*                                                                                                         *;
***********************************************************************************************************;

/* créons la première table par anné avec la table 2002 et 2018 */
proc sql;
create table work.summary_sales_2002_2022_0 as
select year (sale_date) as année,count(*) as nb_transactions, sum(sale_price) as som_pris_vendus
from input.Property_2002_2018
group by année;
quit;

/* créons la première table par anné avec la table 2022*/
proc sql;
create table work.summary_sales_2002_2022_1 as
select year (sale_date) as année,count(*) as nb_transactions, sum(sale_price) as som_pris_vendus
from input.Property_2022 
group by année;
quit;

/*faisons l'union des deux tables*/
proc sql;
create table output.summary_sales_2002_2022 as
select A.*
from summary_sales_2002_2022_0 as A
union all
select B.*
from summary_sales_2002_2022_1 as B
order by année;
quit;

*****************************************************************************************************;
*                                           SAS                                         *;

******************************************************************************************************;
*                                         question 1
*(7 points) - À partir de la table Property_2022, extraire simplement les colonnes d’intérêt :       *;
*PropType taxkey bdrms finishedsqft rooms sale_price. Renommez les colonnes finishedSqft 
*par Fin_sqft et rooms par Nr_of_rms. Aussi, dans le but de pouvoir identifier l’origine des données,*;
*ajouter une colonne nommée 
*‘flag_file’ et qui prend la valeur 'Property_2022'. Note : pour ne pas avoir des problèmes de format*; 
*à la question suivante, avant la création de la variable flag_file, ajoutez la ligne 
*suivante : format flag_file $50.Faire un filtre également pour ne garder que les propriétés qui sont*;
*de type (PropType) condominium ou residential.                                                      *;
*                                                                                                    *;
**************************************************************************************************** *;

/* extraction des colonnes d'intèrêt à partir de la table Property_2022 */
data Property_2022_1;
set Property_2022 (keep= PropType taxkey bdrms finishedsqft rooms sale_price);
run;

/* On renomme certaines colonnes (finishedsqft et rooms) */
data Property_2022_11
(rename=(finishedsqft=Fin_sqft rooms=Nr_of_rms));
set Property_2022_1;
run;

/* Définir le format de la variable d’origine */
 data Property_2022_10;
 format flag_file $50.;
 flag_file = 'Property_2022';
 set Property_2022_11;

/* On garde seulement les types souhaités */
where PropType = 'Condominium' OR PropType = 'Residential'; 
run;

******************************************************************************************************;
*                                         question 2
*(7 points) - Faire l’union de la table Property_2002_2018  avec la table créée à la question        *;
*précédente en ne gardant que les colonnes : PropType, taxkey bdrms finishedsqft rooms               *;
*sale_price et les propriétés qui sont de type (PropType) condominium ou residential.                *;
*Avec la même logique qu’à la question précédente, construire la variable flag_file qui prend        *;
*la valeur ‘Property_2002_2018’ (indice : utiliser un if else si champ vide).                        *;
*Sauvegardez la table de résultat dans la librairie temporaire avec le nom :                         *;
*union_2002_2022.                                                                                    *;
*                                                                                                    *;
**************************************************************************************************** *;
 **************************************************************************************************** *;

/* extraction des colonnes d'intèrêt à partir de la table Property_2002_2018 */
data work.Property_2002_2018_1;
set input.Property_2002_2018 (keep= PropType taxkey bdrms Fin_sqft  Nr_of_rms sale_price);

/* On garde seulement les types  de propriétés souhaités */
where PropType = 'Condominium' OR PropType = 'Residential'; 
run;

/* Définir le format de la variable d’origine */
data work.Property_2002_2018_10;
format flag_file $50.;
flag_file = 'Property_2002_2018';
set work.Property_2002_2018_1;
run;

/* Union entre Property_2002_2018_10 et Property_2022_10 */
data work.union_2002_2022;
set Property_2002_2018_10 Property_2022_10;

/* Si flag_file est vide, on le complète par sécurité */
if missing(flag_file) then flag_file = 'Property_2002_2018';
run;

********************************************************************************************************;
*                                         question 3
*( À partir des observations de la table union_2002_2022, pour chaque propriété, calculer le prix      *; 
*au pied carré (FinishesSqft) et le prix par pièce (Rooms).Nommez les deux nouvelles colonnes          *; 
*dollars_per_sqft et dollars_per_room.                                                                 *;
*Note : Comme la valeur Rooms prend parfois la valeur de 0 (ce qui sera problématique dans la division)*;
*,appliquez la règle suivante : si Rooms = 0 alors diviser le prix par le nombre de chambres (bdrms) +2*; 
*Sauvegarder le tout dans la librairie output sous le nom price_analysis.                                                                                   *;
****************************************************************************************************    *;
 ****************************************************************************************************   *;

data output.price_analysis;
set work.union_2002_2022;

/* Calcul du prix par pied carré  */
if Fin_sqft> 0 then dollars_per_sqft = sale_price / Fin_sqft;
else dollars_per_sqft = .; /* valeur manquante si pas de surface */

/* Calcul du prix par pièce */
if Nr_of_rms > 0 then dollars_per_room = sale_price / Nr_of_rms;
else dollars_per_room = sale_price / (bdrms + 2); /* règle spéciale */
run;

********************************************************************************************************;
*                                         question 5
*( Calculez le prix moyenne au pied carré et par nombre de pièce de chaque type de propriété (Condo et *;
*Residential) et enregistrez les 4 prix moyens dans des macro variables nommées : condo_price_sqft,*****; 
*condo_price_room, residential_price_sqft, residential_price_room***************************************;                                                                                  *;
*********************************************************************************************************;
********************************************************************************************************;

/* Calcul de moyenne par type de propriété */
/* premier methode */
proc sort data= output.price_analysis;by PropType;run;
proc means data= output.price_analysis mean ;
var dollars_per_sqft dollars_per_room;
by PropType;
run;

/* création des macro-variable */
%let condo_price_sqft = 170.7736803;
%let condo_price_room = 53644.69;
%let residential_price_sqft = 103.9439534;
%let residential_price_room = 26350.26;

/*afficher le contenu des macro-variables */
%put &condo_price_sqft;
%put &condo_price_room;
%put &residential_price_sqft;
%put &residential_price_room;

/* deuxième méthode methode */
proc sort data= output.price_analysis;by PropType;run;
proc means data=output.price_analysis noprint;
by PropType;
var dollars_per_sqft dollars_per_room;
output out=mean_price (drop=_TYPE_ _FREQ_)
mean=mean_sqft mean_room;
run;

data _null_;
set mean_price; 
if PropType = 'Condominium' then do;
call symput('condo_price_sqft', mean_sqft);
call symput('condo_price_room', mean_room);
end;

else if PropType  = 'Residential' then do;
call symput('residential_price_sqft', mean_sqft);
call symput('residential_price_room', mean_room);
end;

run;

/* Étape 3 : afficher le contenu des macro-variables */
%put Condo - $/sqft = &condo_price_sqft , $/room = &condo_price_room;
%put Residential - $/sqft = &residential_price_sqft , $/room = &residential_price_room;

********************************************************************************************************;
*                                         question 5
* Faire le calcul des prix attendus basé sur le prix par pied carré. Utilisez la base créée à la question
2 et les moyennes calculées aux questions 3 et 4. Nommez les nouvelles colonnes estimation_sqft.*********;                                                                                  *;
*********************************************************************************************************;
********************************************************************************************************;

data output.price_estimation_sqft;
set work.union_2002_2022;
/* Calcul du prix attendus (estimé) par pied carré lorsque la propriété est condo */

if PropType = 'Condominium' then do;
estimation_sqft = &condo_price_sqft* Fin_sqft;
end;

/* Calcul du prix attendus (estimé) par pied carré lorsque la propriété est residentiel*/
    else if PropType ='Residential' then do;
    estimation_sqft = &residential_price_sqft*Fin_sqft;
	end;
run;

**************************************************************************************************************;
*                                         question 6
*( Finalement, tout ce que nous avons mis en place serait intéressant d’être fait, mais sous forme ***********;
*d’une fonction. Il faudrait toutefois faire une distinction de traitement dans le commercial et le résidentiel; 
*Quand proptype est condominium ou residential utiliser la logique de la finishedSqft, pour le commercial******; 
*utiliser la surface du lot (lotsize). La fonction prendra donc 1 seul argument que vous nommerez ‘type_propriete’* 
***************************************************************************************************************;

%macro estimation_prix(type_propriete);

/* --- Étape 1 : Filtrer selon le type de propriété dans Property_2022 --- */

data Property_2022_2;
set Property_2022 (keep=PropType taxkey bdrms finishedsqft rooms sale_price Lotsize);
run;

data Property_2022_21(rename=(finishedsqft=Fin_sqft rooms=Nr_of_rms));
set Property_2022_2;
run;

data Property_2022_12;
format flag_file $50.;
set Property_2022_21;
flag_file = 'Property_2022';
where PropType = "&type_propriete";
run;

/* --- Étape 2 : Filtrer selon le type de propriété dans Property_2002_2018 --- */

data work.Property_2002_2018_11;
set input.Property_2002_2018 (keep=PropType taxkey bdrms Fin_sqft Nr_of_rms sale_price Lotsize);
where PropType = "&type_propriete";
run;

data work.Property_2002_2018_12;
format flag_file $50.;
set work.Property_2002_2018_11;
flag_file = 'Property_2002_2018';
run;

/* --- Étape 3 : Union des deux tables --- */
data work.union_2002_2022_1;
set Property_2002_2018_12 Property_2022_12;
if missing(flag_file) then flag_file = 'Property_2002_2018';
run;

/* --- Étape 4 : Calcul du prix par unité --- */
data output.price_analysis_1;
set work.union_2002_2022_1;
if "&type_propriete" in ('Condominium', 'Residential') then do;
if PropType = 'Condominium' then 
dollars_per_sqft_C = sale_price / Fin_sqft;
else if PropType = 'Residential' then
dollars_per_sqft_R = sale_price / Fin_sqft;
end;
if "&type_propriete" = 'Commercial' then 
dollars_per_lotsize = sale_price / Lotsize;
run;

/* --- Étape 5 : Calcul du prix moyen --- */
proc sort data=output.price_analysis_1; by PropType;run;
proc means data=output.price_analysis_1 noprint;
by PropType;
var dollars_per_sqft_C dollars_per_sqft_R dollars_per_lotsize;
output out=mean_price_1 (drop=_TYPE_ _FREQ_)
mean=mean_sqft_C mean_sqft_R mean_Lotsize;
run;

data _null_;
set mean_price_1; 
if PropType = 'Condominium' then do;
call symputx("condo_price_sqft_C", mean_sqft_C);
end;

else if PropType = 'Residential' then do;
call symputx("residential_price_sqft_R", mean_sqft_R);
end;

else if PropType = 'Commercial' then do;
call symputx("commercial_price_Lotsize", mean_Lotsize);
end;

run;

/* création des macro-variable */
%let condo_price_sqft_C = 170.7736803;
%let commercial_price_Lotsize = 49.417322893;
%let residential_price_sqft_R = 103.9439534;

/* ---afficher le contenu des macro-variables --- */
%put &condo_price_sqft_C; 
%put &residential_price_sqft_R;
%put &commercial_price_Lotsize; 

/* --- Étape 6 : Calcul du prix estimé --- */
data output.price_estimation_sqft_1;
set work.union_2002_2022_1;
if "&type_propriete" in ('Condominium','Residential') then do;
if PropType = 'Condominium' then 
estimation_prix_sqft_C = &condo_price_sqft_C*Fin_sqft;
else if PropType = 'Residential' then 
estimation_prix_sqft_R = &residential_price_sqft_R*Fin_sqft;
end;
else if "&type_propriete" = 'Commercial' then 
estimation_prix_Lotsize = &commercial_price_Lotsize*Lotsize;
run;
	
%mend estimation_prix;


*********************************************************************************************************;
*                                         question 7
* (3 points) - Testez la fonction créée à la question 6 avec comme valeur de l’argument Condominium et **;
****Commercial.                                                                                          ;                                                                                  *;
*********************************************************************************************************;
*********************************************************************************************************;

%estimation_prix(Condominium);
%estimation_prix(Commercial);
/*%estimation_prix(Residential);*/ 
/*%put === Exécution terminée pour &type_propriete ===;*/ 

%symdel condo_price_sqft_C;
%symdel commercial_price_Lotsize;
%symdel residential_price_sqft_R; 


