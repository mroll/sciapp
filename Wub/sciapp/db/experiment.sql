create  table `experiment` (
        `id` integer primary key autoincrement,
        `qid` integer,
        `notes` text,
        `procedure` text,
        `resources` text,
        `analysis` text,
        `vars` text
);
