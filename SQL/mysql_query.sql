CREATE DATABASE IF NOT EXISTS itproject1;

USE itproject1;

ALTER DATABASE itproject1 CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE tb_norm_user_acc (
    c_nuname VARCHAR(30),
    c_npasswd VARCHAR(70) NOT NULL,

    PRIMARY KEY(c_nuname)
);

CREATE TABLE tb_norm_user_info (
    c_nuname VARCHAR(30) REFERENCES tb_norm_user_acc(c_nuname),
    c_avatar VARCHAR(500) DEFAULT 'https://www.apple.com/ac/structured-data/images/open_graph_logo.png?201809210816',

    PRIMARY KEY(c_nuname)
);

CREATE TABLE tb_mod_user_acc (
    c_muname VARCHAR(30),
    c_mpasswd VARCHAR(70) NULL,

    PRIMARY KEY(c_muname)
);

CREATE TABLE tb_mod_user_info (
    c_muname VARCHAR(30) REFERENCES tb_mod_user_acc(c_muname),
    c_dis_name NVARCHAR(100) NOT NULL,

    PRIMARY KEY(c_muname)
);

CREATE TABLE tb_posts(
    c_postid INT AUTO_INCREMENT,
    c_title NVARCHAR(500) NOT NULL,
    c_description LONGTEXT NOT NULL,
    c_content LONGTEXT NOT NULL,
    c_datetime_created DATETIME NOT NULL,
    c_author VARCHAR(30) NOT NULL,
    c_aurl NVARCHAR(500) NOT NULL,
    c_category NVARCHAR(50) NOT NULL,
    c_thumbnailUrl NVARCHAR(500) NOT NULL,

    UNIQUE(c_aurl),
    FOREIGN KEY(c_author) REFERENCES tb_mod_user_acc(c_muname),

    PRIMARY KEY(c_postid)
);

CREATE TABLE tb_post_evaluation (
    c_postid INT,
    c_upvote INT DEFAULT 0,
    c_downvote INT DEFAULT 0,

    FOREIGN KEY(c_postid) REFERENCES tb_posts(c_postid),
    PRIMARY KEY(c_postid)
);

CREATE TABLE tb_comments (
    c_author VARCHAR(30),
    c_postid INT,
    c_datetime DATETIME,
    c_content LONGTEXT NOT NULL,

    FOREIGN KEY(c_author) REFERENCES tb_norm_user_acc(c_nuname),
    FOREIGN KEY(c_postid) REFERENCES tb_posts(c_postid),

    PRIMARY KEY(c_author, c_postid, c_datetime)
);

CREATE TABLE tb_userVoteState (
    c_postid INT,
    c_nuname VARCHAR(30),
    c_voteStatus INT, -- 1: UpVote | 0: DownVote | if nonVote then delete record

    FOREIGN KEY(c_postid) REFERENCES tb_posts(c_postid),
    FOREIGN KEY(c_nuname) REFERENCES tb_norm_user_acc(c_nuname),

    PRIMARY KEY(c_postid, c_nuname)
);


-- Procedures

CREATE PROCEDURE insComment
(IN Aauthor VARCHAR(30), IN  Apostid INT, IN Acontent LONGTEXT)
BEGIN
    INSERT itproject1.tb_comments
    (
        c_author,
        c_postid,
        c_datetime,
        c_content
    )
    VALUES
    (   Aauthor,        -- c_author - varchar(30)
        Apostid,         -- c_postid - int
        GETDATE(), -- c_datetime - datetime
        Acontent        -- c_content - LONGTEXT
        );
END;

-- CALL itproject1.insComment(:Aauthor,:Apostid,:Acontent);

CREATE PROCEDURE insMod
(IN Auname VARCHAR(30), IN Apasswd VARCHAR(70), IN Adisname NVARCHAR(100))
BEGIN
    INSERT INTO itproject1.tb_mod_user_acc
    (
        c_muname,
        c_mpasswd
    )
    VALUES
    (   Auname, -- c_muname - varchar(30)
        Apasswd  -- c_mpasswd - varchar(70)
        );
	INSERT INTO itproject1.tb_mod_user_info
	(
	    c_muname,
	    c_dis_name
	)
	VALUES
	(   Auname, -- c_muname - varchar(30)
	    Adisname -- c_dis_name - nvarchar(100)
	    );
END;

-- CALL itproject1.insMod(:Auname,:Apasswd,:Adisname);

CREATE PROCEDURE changePasswdMod
(IN Auname VARCHAR(30), IN Apasswd VARCHAR(70))
BEGIN
    UPDATE itproject1.tb_mod_user_acc
	SET c_mpasswd = Apasswd
	WHERE c_muname = Auname;
END;

-- CALL itproject1.changePasswdMod(:Auname,:Apasswd);

CREATE PROCEDURE insNormUser
(IN Auname VARCHAR(30), IN Apasswd VARCHAR(70))
BEGIN
    INSERT itproject1.tb_norm_user_acc
    (
        c_nuname,
        c_npasswd
    )
    VALUES
    (   Auname, -- c_nuname - varchar(30)
        Apasswd  -- c_npasswd - varchar(70)
        );
	INSERT itproject1.tb_norm_user_info
	(
	    c_nuname,
	    c_avatar
	)
	VALUES
	(   Auname, -- c_nuname - varchar(30)
	    'https://www.apple.com/ac/structured-data/images/open_graph_logo.png?201809210816'  -- c_avatar - varchar(500)
	    );
END;

-- CALL itproject1.insNormUser(:Auname,:Apasswd);

CREATE PROCEDURE changePasswdNorm
(IN Auname VARCHAR(30), IN Apasswd VARCHAR(70))
BEGIN
    UPDATE itproject1.tb_norm_user_acc
	SET c_npasswd = Apasswd
	WHERE c_nuname = Auname;
END;

-- CALL itproject1.changePasswdMod(:Auname,:Apasswd);

CREATE PROCEDURE insPost
(IN Atitle NVARCHAR(500), IN Adescription LONGTEXT, IN Acontent LONGTEXT, IN Aauthor VARCHAR(30), IN Aaurl NVARCHAR(500), IN Acategory NVARCHAR(50), IN AthumbUrl NVARCHAR(500))
BEGIN
	DECLARE AfindPostId INT;

	INSERT itproject1.tb_posts
	(
	    c_title,
	    c_description,
	    c_content,
	    c_datetime_created,
	    c_author,
	    c_aurl,
	    c_category,
	    c_thumbnailUrl
	)
	VALUES
	(   Atitle,       -- c_title - nvarchar(500)
	    Adescription,       -- c_description - LONGTEXT
	    Acontent,       -- c_content - LONGTEXT
	    GETDATE(), -- c_datetime_created - datetime
	    Aauthor,        -- c_author - varchar(30)
	    Aaurl,       -- c_aurl - nvarchar(500)
	    Acategory,       -- c_category - nvarchar(50)
	    AthumbUrl        -- c_thumbnailUrl - nvarchar(500)
	    );

	SELECT AfindPostId = c_postid
	FROM itproject1.tb_posts
	ORDER BY c_datetime_created DESC
	LIMIT 1;

	INSERT itproject1.tb_post_evaluation
	(
	    c_postid,
	    c_upvote,
	    c_downvote
	)
	VALUES
	(   AfindPostId, -- c_postid - int
	    0, -- c_upvote - int
	    0  -- c_downvote - int
	    );
END;

-- CALL itproject1.insPost(:Atitle,:Adescription,:Acontent,:Aauthor,:Aaurl,:Acategory,:AthumbUrl);

CREATE PROCEDURE changePostEval
(IN ApostId INT, IN Aupv INT, IN Adownv INT)
BEGIN
    UPDATE itproject1.tb_post_evaluation
	SET c_upvote = Aupv, c_downvote = Adownv
	WHERE c_postid = ApostId;
END;

-- CALL itproject1.changePostEval(:ApostId,:Aupv,:Adownv);

CREATE PROCEDURE changeVoteState
(IN ApostId INT, IN Auname VARCHAR(30), IN AvoteState INT)	-- 1: up | 0: down | 2: delete record
BEGIN
	DECLARE AfindPostId INT;
	DECLARE AfindUname VARCHAR(30);
	DECLARE Aexisted INT;

	SELECT Aexisted = COUNT(c_nuname)
	FROM itproject1.tb_userVoteState
	WHERE c_nuname = Auname AND c_postid = ApostId;

	IF Aexisted = 0 THEN
		BEGIN
			INSERT itproject1.tb_userVoteState
			(
				c_postid,
				c_nuname,
				c_voteStatus
			)
			VALUES
			(   ApostId,  -- c_postid - int
				Auname, -- c_nuname - varchar(30)
				AvoteState   -- c_voteStatus - int
				);

			IF AvoteState = 1 THEN
				UPDATE tb_post_evaluation
				SET c_upvote = c_upvote + 1
				WHERE c_postid = ApostId;
			ELSEIF AvoteState = 0 THEN
				UPDATE tb_post_evaluation
				SET c_downvote = c_downvote + 1
				WHERE c_postid = ApostId;
			END IF;
		END;
	ELSE
		BEGIN
			DECLARE AcurrentVState INT;

			SELECT AcurrentVState = c_voteStatus
			FROM tb_userVoteState
			WHERE c_nuname = Auname AND c_postid = ApostId;

			IF AvoteState = 2 THEN
				BEGIN
					DELETE FROM itproject1.tb_userVoteState
					WHERE c_postid = ApostId AND c_nuname = Auname;

					IF AcurrentVState = 1 THEN
						UPDATE tb_post_evaluation
						SET c_upvote = c_upvote - 1
						WHERE c_postid = ApostId;
					ELSE
						UPDATE tb_post_evaluation
						SET c_downvote = c_downvote - 1
						WHERE c_postid = ApostId;
					END IF;
				END;
			ELSE
				BEGIN
					UPDATE itproject1.tb_userVoteState
					SET c_voteStatus = AvoteState
					WHERE c_postid = ApostId AND c_nuname = Auname;

					IF AvoteState = 1 THEN
						UPDATE tb_post_evaluation
						SET c_upvote = c_upvote + 1, c_downvote = c_downvote - 1
						WHERE c_postid = ApostId;
					ELSE
						UPDATE tb_post_evaluation
						SET c_upvote = c_upvote - 1, c_downvote = c_downvote + 1
						WHERE c_postid = ApostId;
					END IF;
				END;
			END IF;
		END;
	END IF;
END;

-- CALL itproject1.changeVoteState(:ApostId,:Auname,:AvoteState);

CREATE PROCEDURE getTenArticles
(IN ApageNum INT, IN Acategory NVARCHAR(50))
BEGIN
	IF Acategory = N'default' THEN
		SELECT *
		FROM (
			SELECT *, ROW_NUMBER() OVER(ORDER BY c_postid DESC) AS RN
			FROM tb_posts
		) as sl1
		WHERE RN BETWEEN 10 * (ApageNum - 1) + 1 AND 10 * (ApageNum)
		ORDER BY c_postid DESC;
	ELSE
		SELECT *
		FROM (
			SELECT *, ROW_NUMBER() OVER(ORDER BY c_postid DESC) AS RN
			FROM tb_posts
			WHERE c_category = Acategory
		) as sl2
		WHERE RN BETWEEN 10 * (ApageNum - 1) + 1 AND 10 * (ApageNum)
		ORDER BY c_postid DESC;
	END IF;
END;

-- CALL itproject1.getTenArticles(1,'android');

CREATE PROCEDURE getTenArticlesEval
(IN ApageNum INT, IN Acategory NVARCHAR(50))
BEGIN
	IF Acategory = N'default' THEN
		SELECT *
		FROM (
			SELECT *,ROW_NUMBER() OVER(ORDER BY tb_post_evaluation.c_postid DESC) AS RN
			FROM tb_post_evaluation
		) AS sl3
		WHERE RN BETWEEN 10 * (ApageNum - 1) + 1 AND 10 * (ApageNum)
		ORDER BY c_postid DESC;
	ELSE
		SELECT *
		FROM (
			SELECT tb_post_evaluation.c_postid, tb_post_evaluation.c_upvote, tb_post_evaluation.c_downvote ,ROW_NUMBER() OVER(ORDER BY tb_post_evaluation.c_postid DESC) AS RN
			FROM tb_post_evaluation, tb_posts
			WHERE tb_posts.c_postid = tb_post_evaluation.c_postid AND tb_posts.c_category = Acategory
		) AS sl3
		WHERE RN BETWEEN 10 * (ApageNum - 1) + 1 AND 10 * (ApageNum)
		ORDER BY c_postid DESC;
	END IF;
END;

-- CALL itproject1.getTenArticlesEval(:ApageNum,:Acategory);
