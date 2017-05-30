create  table `experiment` (
        `id` integer primary key autoincrement,
        `qid` integer,
        `hypothesis` text,
        `notes` text,
        `vars` text
);
