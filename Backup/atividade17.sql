-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 07/08/2024 às 19:55
-- Versão do servidor: 10.4.32-MariaDB
-- Versão do PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `atividade17`
--

DELIMITER $$
--
-- Procedimentos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `attProd` ()   BEGIN
    DECLARE total INT;

    SELECT COUNT(*) INTO total FROM produto;

    TRUNCATE TABLE informacoes_produto;
    INSERT INTO informacoes_produto (total_produtos) VALUES (total);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `aumentarValorProd` (IN `id_produto` INT, OUT `valor_atual` DECIMAL(10,2))   BEGIN

    SELECT valor INTO valor_atual
    FROM produto
    WHERE id_produto = id_produto;

    UPDATE produto
    SET valor = valor * 1.50
    WHERE id_produto = id_produto;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AumentarValorProduto` (IN `p_id_produto` INT, IN `p_percentual` DECIMAL(5,2), OUT `p_valor_atualizado` DECIMAL(10,2))   BEGIN
	DECLARE v_valor_atual DECIMAL(10, 2);

	SELECT valor INTO v_valor_atual
    FROM produto
    WHERE id_produto = p_id_produto;

    UPDATE produto
    SET valor = v_valor_atual * (1 + p_percentual)
    WHERE id_produto = p_id_produto;

    SELECT valor INTO p_valor_atualizado
    FROM produto
    WHERE id_produto = p_id_produto;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `buscarProdutoCodigo` (IN `codigo_produto` INT)   BEGIN
    DECLARE nome_produto VARCHAR(255);
    DECLARE valor DECIMAL(10, 2);
    DECLARE mensagem VARCHAR(255);

    SET mensagem = 'Produto não existe ou não foi encontrado';

    -- Tenta encontrar o produto
    SELECT nome_produto, valor
    INTO nome_produto, valor
    FROM produto
    WHERE id_produto = codigo_produto;

    IF nome_produto IS NOT NULL THEN
        SELECT nome_produto AS nome, valor AS valor, NULL AS mensagem;
    ELSE
        SELECT NULL AS nome_produto, NULL AS valor, mensagem AS mensagem;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `conferir_estoque` ()   BEGIN
	select produto.nome_produto, produto.qtd from produto; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `contVendedor` ()   BEGIN
	select count(id_vendedor) from vendedor;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `contVendedores` ()   BEGIN
	SELECT COUNT(*) AS total_vendedores FROM vendedor;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `diminuirValorProd` (IN `p_id_produto` INT, IN `p_percentual` DECIMAL(5,2), OUT `p_valor_atualizado` DECIMAL(10,2))   BEGIN
    DECLARE v_valor_atual DECIMAL(10, 2);

    -- Obtém o valor atual do produto
    SELECT valor INTO v_valor_atual
    FROM produto
    WHERE id_produto = p_id_produto;

    UPDATE produto
    SET valor = v_valor_atual * (1 - p_percentual)
    WHERE id_produto = p_id_produto;

    SELECT valor INTO p_valor_atualizado
    FROM produto
    WHERE id_produto = p_id_produto;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `excSeNassociado` (IN `p_id_produto` INT)   BEGIN
    DECLARE produto_esta_associado INT;

    -- Verifique se o produto está associado a uma venda
    SELECT COUNT(*)
    INTO produto_esta_associado
    FROM tem
    WHERE id_produto = p_id_produto;

    -- Exclua o produto se não estiver associado a uma venda
    IF produto_esta_associado = 0 THEN
        DELETE FROM produto WHERE id_produto = p_id_produto;
    ELSE
        SELECT 'O produto está associado a uma venda e não pode ser excluído.' AS Mensagem;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listProd` ()   BEGIN
	select nome_produto from produto;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sexoFunc` ()   BEGIN
    -- Contagem de vendedores por sexo
    SELECT 'Feminino' AS Sexo, COUNT(sexo) AS Quantidade
    FROM vendedor
    WHERE sexo = 'F'
    UNION ALL
    SELECT 'Masculino' AS Sexo, COUNT(sexo) AS Quantidade
    FROM vendedor
    WHERE sexo = 'M';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `valorConvertidos` ()   BEGIN
    set @taxa_dolar = 0.20;
    set @taxa_euro = 0.18;

    select nome_produto, valor as valor_em_reais, valor * @taxa_dolar as valor_em_dolar, valor * @taxa_euro AS valor_em_euro from produto;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `valorMinMax` ()   BEGIN
	select nome_produto, valor from produto where valor = (SELECT MAX(valor) FROM produto);
    select nome_produto, valor from produto where valor = (SELECT MIN(valor) FROM produto);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `vend_centro_proc` (IN `p_loja` VARCHAR(50), IN `p_qtd_registo` INT)   BEGIN
	select * from vendedor where loja = "loja Centro" order by rand();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verificaEstoque` ()   BEGIN
SELECT
    id_produto,
    nome_produto,
    qtd,
    CASE
        WHEN qtd > 10 THEN 'Estoque OK'
        WHEN qtd >= 5 THEN 'Estoque Adequado'
        WHEN qtd >= 2 THEN 'Alerta para Nova Reposição'
        ELSE 'Reabastecimento Urgente'
    END AS status_estoque
FROM
    produto;

END$$

--
-- Funções
--
CREATE DEFINER=`root`@`localhost` FUNCTION `BuscarVendedorPorCodigo` (`p_codigo_vendedor` INT) RETURNS VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC BEGIN
    DECLARE v_nome VARCHAR(255);

    SET v_nome = 'Vendedor não existe ou não foi encontrado';

    SELECT nome INTO v_nome
    FROM vendedor
    WHERE id_vendedor = p_codigo_vendedor;

    RETURN v_nome;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `produto`
--

CREATE TABLE `produto` (
  `id_produto` int(11) NOT NULL,
  `nome_produto` varchar(80) NOT NULL,
  `qtd` int(11) NOT NULL,
  `valor` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `produto`
--

INSERT INTO `produto` (`id_produto`, `nome_produto`, `qtd`, `valor`) VALUES
(10, 'Mouse Gamer Corsair Harpoon PRO', 15, 231.03),
(11, 'Microsoft Office Home 2021', 11, 1406.9),
(12, 'HD Externo Seagate Expansion 2TB', 18, 578.589),
(13, 'Teclado Mecânico Gamer HyperX', 23, 809.49),
(15, 'Teclado Mecânico Gamer HyperX', 9, 385.06),
(16, 'Mouse Gamer Corsair Harpoon PRO', 50, 495.06),
(17, 'Fone de Ouvido Havit HV-H2002d', 48, 240.9),
(18, 'Mouse Gamer Revo', 60, 55.01),
(19, 'Mousepad Grande', 18, 82.515),
(20, 'Geforce GT740', 98, 550),
(21, 'Fone de Ouvido Havit HV-H2002d', 50, 240.9),
(22, 'Teclado Mecânico Redragon K552', 30, 149.5065),
(23, 'Mouse Gamer Logitech G502', 45, 273.93),
(24, 'Monitor 24\" LG UltraWide', 18, 768.91),
(25, 'HD Externo Seagate 1TB', 40, 384.89),
(26, 'Smartwatch Apple Watch Series 8', 23, 3848.9),
(27, 'Cadeira Gamer DXRacer Racing', 10, 1428.9),
(28, 'Microfone Condensador USB Blue Yeti', 12, 713.9),
(29, 'Webcam Logitech C920', 35, 427.9),
(30, 'Roteador TP-Link Archer AX50', 20, 548.9);

-- --------------------------------------------------------

--
-- Estrutura para tabela `tem`
--

CREATE TABLE `tem` (
  `id_produto` int(11) NOT NULL,
  `id_venda` int(11) NOT NULL,
  `qtd_item` int(11) NOT NULL,
  `valor_item` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `tem`
--

INSERT INTO `tem` (`id_produto`, `id_venda`, `qtd_item`, `valor_item`) VALUES
(10, 1001, 5, 210),
(10, 1002, 1, 210),
(10, 1003, 2, 420),
(11, 1001, 1, 990.5),
(12, 1002, 1, 525.99),
(15, 1005, 1, 350),
(16, 1006, 1, 450),
(17, 1007, 1, 219),
(18, 1008, 1, 250),
(19, 1009, 1, 50),
(20, 1010, 1, 500),
(22, 1011, 1, 159.9),
(24, 1015, 1, 699),
(26, 1012, 1, 3499),
(30, 1013, 1, 499);

--
-- Acionadores `tem`
--
DELIMITER $$
CREATE TRIGGER `att_prod` AFTER INSERT ON `tem` FOR EACH ROW BEGIN
	DECLARE valor_calculado DECIMAL(10, 2);
    
    UPDATE produto
    SET qtd = qtd - NEW.qtd_item
    WHERE id_produto = NEW.id_produto;
    
    UPDATE venda
    SET valor_venda = (
        SELECT SUM(qtd_item * valor_item)
        FROM tem
        WHERE id_venda = NEW.id_venda
    )
    WHERE id_venda = NEW.id_venda;
        
	UPDATE produto
    SET qtd = qtd - NEW.qtd_item
    WHERE id_produto = NEW.id_produto;

    SELECT SUM(qtd_item * valor_item) INTO valor_calculado
    FROM tem
    WHERE id_venda = NEW.id_venda;

    IF valor_calculado <> (SELECT valor_venda FROM venda WHERE id_venda = NEW.id_venda) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valor da venda incorreto';
    END IF;

    UPDATE venda
    SET valor_venda = valor_calculado
    WHERE id_venda = NEW.id_venda;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `deletar_prod` AFTER DELETE ON `tem` FOR EACH ROW BEGIN
	UPDATE produto
    SET qtd = qtd + OLD.qtd_item
    WHERE id_produto = OLD.id_produto;
    
    UPDATE venda
    SET valor_venda = (
        SELECT SUM(qtd_item * valor_item)
        FROM tem
        WHERE id_venda = OLD.id_venda
    )
    WHERE id_venda = OLD.id_venda;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `upd_item` AFTER UPDATE ON `tem` FOR EACH ROW BEGIN
	UPDATE produto
    SET qtd = qtd + OLD.qtd_item
    WHERE id_produto = OLD.id_produto;

    UPDATE produtos
    SET qtd = qtd - NEW.qtd_item
    WHERE id_produto = NEW.id_produto;
    
	UPDATE venda
    SET valor_venda = (
        SELECT SUM(qtd_item * valor_item)
        FROM tem
        WHERE id_venda = NEW.id_venda
    )
    WHERE id_venda = NEW.id_venda;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `total_vendas_view`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `total_vendas_view` (
`total_vendas` double
);

-- --------------------------------------------------------

--
-- Estrutura para tabela `venda`
--

CREATE TABLE `venda` (
  `id_venda` int(11) NOT NULL,
  `data_venda` date NOT NULL,
  `valor_venda` double NOT NULL,
  `id_vendedor` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `venda`
--

INSERT INTO `venda` (`id_venda`, `data_venda`, `valor_venda`, `id_vendedor`) VALUES
(1001, '2022-06-22', 2040.5, 101),
(1002, '2022-06-30', 735.99, 102),
(1003, '2022-07-02', 420, 103),
(1004, '2022-06-28', 0, 101),
(1005, '2022-07-02', 350, 101),
(1006, '2022-07-10', 450, 101),
(1007, '2022-07-20', 219, 101),
(1008, '2022-07-22', 250, 109),
(1009, '2022-08-02', 50, 107),
(1010, '2022-08-11', 500, 106),
(1011, '2023-02-22', 159.9, 101),
(1012, '2023-03-25', 3499, 109),
(1013, '2023-08-12', 499, 107),
(1014, '2022-08-17', 0, 106),
(1015, '2022-09-27', 699, 102);

-- --------------------------------------------------------

--
-- Estrutura para tabela `vendedor`
--

CREATE TABLE `vendedor` (
  `id_vendedor` int(11) NOT NULL,
  `nome` varchar(80) NOT NULL,
  `sexo` varchar(50) NOT NULL,
  `loja` varchar(50) NOT NULL,
  `email` varchar(60) DEFAULT NULL,
  `data_nascimento` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `vendedor`
--

INSERT INTO `vendedor` (`id_vendedor`, `nome`, `sexo`, `loja`, `email`, `data_nascimento`) VALUES
(101, 'Aldebaran Silva', 'M', 'loja Centro', 'aldebaranp@gghardware.com.br', '1970-03-13'),
(102, 'Carina Dias', 'F', 'loja Santo Antônio', 'carina@gghardware.com.br', '1982-05-24'),
(103, 'Nicolle Cherry', 'F', 'loja Floresta', 'nicolle@gghardware.com.br', '1990-11-15'),
(104, 'João da Silva', 'M', 'loja Centro', 'joao.silva@gghardware.com.br', '1975-02-28'),
(105, 'Maria Oliveira', 'F', 'loja Santo Antônio', 'maria.oliveira@gghardware.com.br', '1988-09-04'),
(106, 'Pedro Santos', 'M', 'loja Floresta', 'pedro.santos@gghardware.com.br', '1978-12-12'),
(107, 'Ana Costa', 'F', 'loja Centro', 'ana.costa@gghardware.com.br', '1985-07-21'),
(108, 'Carlos Oliveira', 'M', 'loja Santo Antônio', 'carlos.oliveira@gghardware.com.br', '1992-10-30'),
(109, 'Juliana Santos', 'F', 'loja Floresta', 'juliana.santos@gghardware.com.br', '1980-06-17'),
(110, 'Arthur Correa', 'M', 'loja Floresta', 'arthurbarbosakk@gghardware.com.br', '2007-10-25');

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `vend_centro`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `vend_centro` (
`id_vendedor` int(11)
,`nome` varchar(80)
,`sexo` varchar(50)
,`loja` varchar(50)
,`email` varchar(60)
);

-- --------------------------------------------------------

--
-- Estrutura para view `total_vendas_view`
--
DROP TABLE IF EXISTS `total_vendas_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `total_vendas_view`  AS SELECT sum(`venda`.`valor_venda`) AS `total_vendas` FROM `venda` ;

-- --------------------------------------------------------

--
-- Estrutura para view `vend_centro`
--
DROP TABLE IF EXISTS `vend_centro`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vend_centro`  AS SELECT `vendedor`.`id_vendedor` AS `id_vendedor`, `vendedor`.`nome` AS `nome`, `vendedor`.`sexo` AS `sexo`, `vendedor`.`loja` AS `loja`, `vendedor`.`email` AS `email` FROM `vendedor` WHERE `vendedor`.`loja` = 'loja Centro' ORDER BY rand() ASC ;

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `produto`
--
ALTER TABLE `produto`
  ADD PRIMARY KEY (`id_produto`),
  ADD UNIQUE KEY `id_produto_UNIQUE` (`id_produto`);

--
-- Índices de tabela `tem`
--
ALTER TABLE `tem`
  ADD PRIMARY KEY (`id_produto`,`id_venda`),
  ADD KEY `fk_produto_has_venda_venda1_idx` (`id_venda`),
  ADD KEY `fk_produto_has_venda_produto_idx` (`id_produto`);

--
-- Índices de tabela `venda`
--
ALTER TABLE `venda`
  ADD PRIMARY KEY (`id_venda`,`id_vendedor`),
  ADD UNIQUE KEY `id_venda_UNIQUE` (`id_venda`),
  ADD KEY `fk_venda_vendedor1_idx` (`id_vendedor`);

--
-- Índices de tabela `vendedor`
--
ALTER TABLE `vendedor`
  ADD PRIMARY KEY (`id_vendedor`),
  ADD UNIQUE KEY `id_vendedor_UNIQUE` (`id_vendedor`);

--
-- AUTO_INCREMENT para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `produto`
--
ALTER TABLE `produto`
  MODIFY `id_produto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT de tabela `venda`
--
ALTER TABLE `venda`
  MODIFY `id_venda` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1016;

--
-- AUTO_INCREMENT de tabela `vendedor`
--
ALTER TABLE `vendedor`
  MODIFY `id_vendedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=133;

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `tem`
--
ALTER TABLE `tem`
  ADD CONSTRAINT `fk_produto_has_venda_produto` FOREIGN KEY (`id_produto`) REFERENCES `produto` (`id_produto`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_produto_has_venda_venda1` FOREIGN KEY (`id_venda`) REFERENCES `venda` (`id_venda`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Restrições para tabelas `venda`
--
ALTER TABLE `venda`
  ADD CONSTRAINT `fk_venda_vendedor1` FOREIGN KEY (`id_vendedor`) REFERENCES `vendedor` (`id_vendedor`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
