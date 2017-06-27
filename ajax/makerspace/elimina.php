<?php
  require_once('../../inc/carica.inc.php');

  $autenticazione = new Autenticazione($mysqli);

  header('Content-Type: application/json');

  $id = $mysqli -> real_escape_string(isset($_POST['id']) ? trim($_POST['id']) : '');

  function stampaErrore($errore = 'Errore sconosciuto!') {
    echo '{"errore":true,"msg":"'.$errore.'"}';
    exit();
  }

  // Controllo che l'utente abbia effettuato l'accesso
  if(!$autenticazione -> isLogged())

    // L'utente non ha effettuato l'accesso
    stampaErrore('Non hai effettuato l\'accesso!');

  // Controllo che l'utente abbia i permessi per effettuare la modifica
  else if($autenticazione -> gestionePortale != 1)

    // L'utente non ha i permessi
    stampaErrore('Non sei autorizzato ad effettuare la modifica!');

  // L'utente ha effettuato l'accesso ed è autorizzato
  else {

    // Controllo che il nome del Maker Space sia valido
    if(!preg_match("/^[0-9]+$/", $id))
      stampaErrore('ID del Maker Space non valido!');

    // Controllo che il Maker Space non esista già
    $sql = "SELECT * FROM makerspace WHERE id = '{$id}'";
    $query = $mysqli -> query($sql);

    if(!$query) {
      $console -> alert("Impossibile eseguire la query di verifica esistenza Maker Space! ".$mysqli -> error, $autenticazione -> id);
      stampaErrore('Impossibile completare la richiesta!');
    }

    if($query -> num_rows != 1)
      stampaErrore('Il Maker Space non esiste!');

    $mksp = $query -> fetch_array();

    // Creo il Maker Space
    $sql = "DELETE FROM makerspace WHERE id = '{$id}'";
    $query = $mysqli -> query($sql);

    if(!$query) {
      $console -> alert("Impossibile eseguire la query di eliminazione del Maker Space! ".$mysqli -> error, $autenticazione -> id);
      stampaErrore('Impossibile completare la richiesta!');
    }

    echo '{}';
    $console -> warn("Eliminato il Maker Space \"{$mksp['nome']}\" (ID: {$id}).", $autenticazione -> id);
  }
?>