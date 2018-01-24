<?php
  require_once('../inc/autenticazione.inc.php');

  $permessiUtente = $permessi -> whatCanHeDo($autenticazione -> id);
  $dashboard = $permessiUtente['dashboard']['stato'];
  $templates = $permessiUtente['visualizzareTemplate']['stato'];
  $diz = $permessiUtente['dizionario']['stato'];
  $makerspace = $permessiUtente['visualizzareMakerSpace']['stato'];
  $log = $permessiUtente['visualizzareLog']['stato'];
  $ricerca = $permessiUtente['visualizzareUtenti']['stato'];
  $gruppi = $permessiUtente['visualizzareGruppi']['stato'];
  $badge = $permessiUtente['visualizzareBadge']['stato'];

  $aggiuntaModificaCorsi = $permessiUtente['aggiuntaModificaCorsi']['stato'];
  $visAvanzataCorsi = $permessiUtente['visualizzazioneAvanzataCorsi']['stato'];

  if(!$ricerca && !$gruppi && !$badge && !$makerspace && !$log
      && !$diz && !$templates && !$dashboard
      && !$aggiuntaModificaCorsi && !$visAvanzataCorsi)
    header('Location: /');
?>
<!DOCTYPE html>
<html lang="it">
  <head>
    <?php
      require_once('../inc/header.inc.php');
    ?>
    <link type="text/css" rel="stylesheet" media="screen" href="/css/dashboard.css" />
  </head>
  <body>
    <?php
      include_once('../inc/nav.inc.php');
    ?>
    <div id="contenuto">
      <h1>Gestione</h1>
      <div id="contenitoreBox">
        <div class="box">
          <div class="titolo">
            <p>Utenti</p>
          </div>
          <div class="descrizione">
            <p>Pannello di gestione degli utenti.</p>
            <a href="/gestione/utenti/" class="button">Apri Gestione Utenti</a>
          </div>
        </div>
        <?php
          if($diz || $templates || $dashboard) {
        ?>
        <div class="box">
          <div class="titolo">
            <p>Generale</p>
          </div>
          <div class="descrizione">
            <p>Pannello di gestione della dashboard e di altre funzioni.</p>
            <a href="/gestione/generale/" class="button">Apri Gestione Generale</a>
          </div>
        </div>
        <?php
          }

          if($makerspace) {
        ?>
        <div class="box">
          <div class="titolo">
            <p>Maker Space</p>
          </div>
          <div class="descrizione">
            <p>Pannello di gestione dei Maker Space.</p>
            <a href="/gestione/makerspace/" class="button">Apri Gestione Maker Space</a>
          </div>
        </div>
        <?php
          }

          if($aggiuntaModificaCorsi || $visAvanzataCorsi) {
        ?>
        <div class="box">
          <div class="titolo">
            <p>Gestione Corsi</p>
          </div>
          <div class="descrizione">
            <p>Pannello di controllo avanzato dei corsi.</p>
            <a href="/gestione/corsi/" class="button">Apri Gestione Corsi</a>
          </div>
        </div>
        <?php
          }

          if($log) {
        ?>
        <div class="box">
          <div class="titolo">
            <p>Log</p>
          </div>
          <div class="descrizione">
            <p>Elenco dei log del portale.</p>
            <a href="/gestione/logs.php" class="button">Vai a Log</a>
          </div>
        </div>
        <?php
          }
        ?>
      </div>
    </div>
    <?php
      include_once('../inc/footer.inc.php');
    ?>
  </body>
</html>
