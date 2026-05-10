set search_path to public;

/*
 ==========================================

 (BR-02) Le nombre de convives d'une réservation confirmée ou terminée ne peut pas dépasser la capacité totale
 des tables associées à la réservation.
 Ceci implique qu'une réservation confirmée ou terminée doit avoir au moins une table réservée
 appartenant au restaurant de la réservation.

 ==========================================
 */


