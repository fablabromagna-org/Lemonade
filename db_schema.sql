create schema if not exists lemonade collate utf8mb4_bin;

create table if not exists comuni
(
  belfiore     char(4)     default '' not null
    primary key,
  nome         varchar(75) default '' not null,
  stato_estero tinyint(1)  default 0  not null
);

create table if not exists files
(
  id_file        int(11) unsigned auto_increment
    primary key,
  nome           varchar(255) null,
  mime           varchar(255) null,
  file           longblob     not null,
  ts_inserimento int(11)      not null,
  sha256         char(64) generated always as (sha2(`file`, 256)) stored,
  md5            char(32) generated always as (md5(`file`)) stored
);

create table if not exists email_templates
(
  nome    varchar(255)     not null
    primary key,
  id_file int(11) unsigned not null,
  oggetto varchar(255)     not null,
  foreign key (id_file) references files (id_file)
    on delete restrict
    on update cascade
);

create table if not exists firewall
(
  id_regola_firewall int(11) unsigned auto_increment
    primary key,
  action             varchar(20) default '' not null comment 'accept|reject',
  ip                 varchar(39)            not null,
  cidr               tinyint(2) unsigned    not null,
  ts_scadenza        int                    null
);

create table if not exists gruppi
(
  id_gruppo   int(11) unsigned auto_increment
    primary key,
  nome        varchar(25)          not null,
  descrizione varchar(240)         null,
  eliminato   tinyint(1) default 0 not null,
  `default`   tinyint(1) default 1 not null
);

create table if not exists permessi
(
  id_permesso      int(11) unsigned auto_increment
    primary key,
  utente           tinyint(1) default 1 not null,
  id_utente_gruppo int(11) unsigned     not null,
  permesso         varchar(255)         not null,
  valore           tinyint(1)           not null,
  constraint vincolo_permesso
    unique (utente, id_utente_gruppo, permesso)
);

create table if not exists province
(
  id_provincia int(11) unsigned auto_increment
    primary key,
  nome         varchar(40) not null
);

create table if not exists regioni
(
  id_regione int(11) unsigned auto_increment
    primary key,
  nome       varchar(40) not null
);

create table if not exists registro
(
  id_oggetto     int(11) unsigned auto_increment
    primary key,
  ts_inserimento int          not null,
  pacchetto      varchar(255) not null,
  oggetto        varchar(255) not null,
  note           text         not null,
  ip             varchar(39)  null
);

create table if not exists scuole
(
  codice        char(10)         not null
    primary key,
  denominazione varchar(255)     not null,
  indirizzo     varchar(255)     not null,
  comune        char(4)          not null,
  provincia     int(11) unsigned not null,
  regione       int(11) unsigned not null,
  foreign key (comune) references comuni (belfiore)
    on delete restrict
    on update cascade,
  foreign key (provincia) references province (id_provincia)
    on delete restrict
    on update cascade,
  foreign key (regione) references regioni (id_regione)
    on delete restrict
    on update cascade
);

create table if not exists utenti
(
  id_utente          int(11) unsigned auto_increment
    primary key,
  nome               varchar(125)         not null,
  cognome            varchar(125)         not null,
  email              varchar(255)         null,
  data_registrazione int                  not null,
  ip_registrazione   varchar(39)          not null,
  sospeso            tinyint(1) default 0 not null,
  codice_attivazione varchar(13)          null,
  data_nascita       int                  null,
  codice_fiscale     varchar(16)          null,
  luogo_nascita      char(4)              null,
  sesso              tinyint(1)           null,
  secretato          tinyint(1) default 0 not null,
  id_foto            int(11) unsigned     null,
  foreign key (luogo_nascita) references comuni (belfiore)
    on delete set null
    on update cascade,
  foreign key (id_foto) references files (id_file)
    on delete set null
    on update cascade
);

create table if not exists password
(
  id_password    int(11) unsigned auto_increment
    primary key,
  id_utente      int(11) unsigned not null,
  password       varchar(255)     not null,
  ts_inserimento int              not null,
  foreign key (id_utente) references utenti (id_utente)
    on delete cascade
    on update cascade
);

create table if not exists log
(
  id_log    int(11) unsigned auto_increment
    primary key,
  id_utente int(11) unsigned null,
  ip        varchar(39)      not null,
  pacchetto varchar(255)     not null,
  oggetto   varchar(255)     not null,
  testo     text             not null,
  debug     text             null,
  ts        int              not null,
  livello   tinyint(1)       not null comment '0 = trace, 1 = info, 2 = warn, 3 = error',
  foreign key (id_utente) references utenti (id_utente)
    on delete set null
    on update cascade
);

create table if not exists relazioni_scuola
(
  id_relazione int(11) unsigned auto_increment
    primary key,
  utente       int(11) unsigned not null,
  scuola       char(10)         not null,
  ruolo        tinyint(1)       not null comment '0 studente, 1 docente, 2 personale',
  classe       tinyint(1)       null,
  sezione      varchar(5)       null,
  foreign key (utente) references utenti (id_utente)
    on delete cascade
    on update cascade,
  foreign key (scuola) references scuole (codice)
    on delete cascade
    on update cascade
);

create table if not exists sessioni
(
  id_sessione        int(11) unsigned auto_increment
    primary key,
  id_utente          int(11) unsigned     not null,
  token              varchar(23) unique   not null,
  tipo_dispositivo   varchar(50)          not null,
  user_agent         varchar(255)         not null,
  ts_creazione       int                  not null,
  ts_scadenza        int                  not null,
  ts_ultima_attivita int                  not null,
  terminata          tinyint(1) default 0 not null,
  foreign key (id_utente) references utenti (id_utente)
    on delete cascade
    on update cascade
);

create table if not exists utenti_gruppi
(
  id_utente int(11) unsigned not null,
  id_gruppo int(11) unsigned not null,
  constraint index_associazione
    unique (id_utente, id_gruppo),
  foreign key (id_utente) references utenti (id_utente)
    on delete cascade
    on update cascade,
  foreign key (id_gruppo) references gruppi (id_gruppo)
    on delete cascade
    on update cascade
);

create table if not exists tag
(
  id_tag int(11) unsigned auto_increment
    primary key,
  nome   varchar(30) not null unique
);

create table if not exists fascicoli_personali
(
  id_elemento      int(11) unsigned auto_increment
    primary key,
  id_utente        int(11) unsigned not null,
  oggetto          varchar(75)      null,
  descrizione      text             null,
  autore           int(11) unsigned null,
  data_inserimento int(11)          not null,
  data_modifica    int(11)          null,
  foreign key (id_utente) references utenti (id_utente)
    on delete cascade
    on update cascade,
  foreign key (autore) references utenti (id_utente)
    on delete set null
    on update cascade
);

create table if not exists tag_fascicoli_personali
(
  id_elemento int(11) unsigned not null,
  tag         int(11) unsigned not null,
  constraint associazione_unica
    unique (id_elemento, tag),
  foreign key (id_elemento) references fascicoli_personali (id_elemento)
    on delete cascade
    on update cascade,
  foreign key (tag) references tag (id_tag)
    on delete cascade
    on update cascade
);

create table if not exists allegati_fascicoli_personali
(
  id_elemento int(11) unsigned not null,
  id_file     int(11) unsigned not null,
  constraint associazione_unica
    unique (id_elemento, id_file),
  foreign key (id_elemento) references fascicoli_personali (id_elemento)
    on delete cascade
    on update cascade,
  foreign key (id_file) references files (id_file)
    on delete cascade
    on update cascade
);

create table if not exists allegati_template_email
(
  nome     varchar(255)     not null,
  id_file  int(11) unsigned not null,
  embedded tinyint(1)       not null default false,
  constraint associazione_unica
    unique (nome, id_file),
  foreign key (nome) references email_templates (nome)
    on delete cascade
    on update cascade,
  foreign key (id_file) references files (id_file)
    on delete cascade
    on update cascade
);

create table if not exists makerspace
(
  id_makerspace int(11) unsigned auto_increment primary key,
  nome          varchar(255),
  eliminato     tinyint(1) not null default false
);

create table if not exists badge
(
  id_assegnazione     int(11) unsigned auto_increment
    primary key,
  rfid                char(10)         not null,
  data_assegnazione   int(11),
  utente_assegnazione int(11) unsigned not null,
  revocato            tinyint(1)       not null default false,
  foreign key (utente_assegnazione) references utenti (id_utente)
    on delete cascade
    on update cascade
);

create table if not exists totem
(
  id_totem      int(11) unsigned auto_increment
    primary key,
  id_makerspace int(11) unsigned not null,
  nome          varchar(255)     not null,
  test          tinyint(1)       not null default false,
  token         char(36)         not null,
  foreign key (id_makerspace) references makerspace (id_makerspace)
    on delete cascade
    on update cascade
);

create table if not exists presenze
(
  id_presenza     int(11) unsigned auto_increment
    primary key,
  id_utente       int(11) unsigned not null,
  id_totem_inizio int(11) unsigned,
  id_totem_fine   int(11) unsigned,
  orario_inizio   int(11)          not null,
  orario_fine     int(11)          not null,
  badge_inizio    int(11) unsigned,
  badge_fine      int(11) unsigned,
  annullato       tinyint(1)       not null default false,
  foreign key (id_utente) references utenti (id_utente)
    on delete cascade
    on update cascade,
  foreign key (id_totem_inizio) references totem (id_totem)
    on delete cascade
    on update cascade,
  foreign key (id_totem_fine) references totem (id_totem)
    on delete cascade
    on update cascade,
  foreign key (badge_inizio) references badge (id_assegnazione)
    on delete cascade
    on update cascade,
  foreign key (badge_fine) references badge (id_assegnazione)
    on delete cascade
    on update cascade
);

create table if not exists attivita
(
  id_attivita   int(11) unsigned auto_increment
    primary key,
  id_utente     int(11) unsigned not null,
  oggetto       varchar(125)     not null,
  descrizione   text,
  link_presenza int(11) unsigned,
  inizio        int(11), # NULL se link_presenza contiene qualcosa
  fine          int(11), # NULL se link_presenza contiene qualcosa
  foreign key (id_utente) references utenti (id_utente)
    on delete cascade
    on update cascade,
  foreign key (link_presenza) references presenze (id_presenza)
    on delete cascade
    on update cascade
);
