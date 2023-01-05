CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE ore_64_8_v1 AS (
  bytes bytea
);

CREATE OR REPLACE FUNCTION compare_ore_64_8_v1(a ore_64_8_v1, b ore_64_8_v1) returns integer AS $$
  DECLARE
    eq boolean := true;
    unequal_block smallint := 0;
    hash_key bytea;
    target_block bytea;

    left_block_size CONSTANT smallint := 16;
    right_block_size CONSTANT smallint := 32;
    right_offset CONSTANT smallint := 136; -- 8 * 17

    indicator smallint := 0;
  BEGIN
    RAISE NOTICE '############'
    RAISE NOTICE 'a: % ', a;
    RAISE NOTICE 'b: % ', b;
    IF a IS NULL AND b IS NULL THEN
      RETURN 0;
    END IF;

    IF a IS NULL THEN
      RETURN -1;
    END IF;

    IF b IS NULL THEN
      RETURN 1;
    END IF;

    -- bytes is now an array of binary strings
    -- check length of array
    -- check bit_length of each binary string within the array
    IF bit_length(a.bytes) != bit_length(b.bytes) THEN
      RAISE EXCEPTION 'Ciphertexts are different lengths';
    END IF;

    FOR block IN 0..7 LOOP
      -- TODO: This isn't complete: need to check the prp values as well as the blocks
      -- Substr is ordinally indexed (hence 9 and not 8)
      IF substr(a.bytes, 9 + left_block_size * block, left_block_size) != substr(b.bytes, 9 + left_block_size * BLOCK, left_block_size) THEN
        -- set the first unequal block we find
        IF eq THEN
          unequal_block := block;
        END IF;
        eq = false;
      END IF;
    END LOOP;

    IF eq THEN
      RETURN 0::integer;
    END IF;

    -- Hash key is the IV from the right CT of b
    hash_key := substr(b.bytes, right_offset + 1, 16);

    -- first right block is at right offset + nonce_size (ordinally indexed)
    target_block := substr(b.bytes, right_offset + 17 + (unequal_block * right_block_size), right_block_size);

    indicator := (
      get_bit(
        encrypt(
          substr(a.bytes, 9 + (left_block_size * unequal_block), left_block_size),
          hash_key,
          'aes-ecb'
        ),
        0
      ) + get_bit(target_block, get_byte(a.bytes, unequal_block))) % 2;

    IF indicator = 1 THEN
      RETURN 1::integer;
    ELSE
      RETURN -1::integer;
    END IF;
  END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION ore_64_8_v1_eq(a ore_64_8_v1, b ore_64_8_v1) RETURNS boolean AS $$
  SELECT compare_ore_64_8_v1(a, b) = 0
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION ore_64_8_v1_neq(a ore_64_8_v1, b ore_64_8_v1) RETURNS boolean AS $$
  SELECT compare_ore_64_8_v1(a, b) <> 0
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION ore_64_8_v1_lt(a ore_64_8_v1, b ore_64_8_v1) RETURNS boolean AS $$
  SELECT compare_ore_64_8_v1(a, b) = -1
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION ore_64_8_v1_lte(a ore_64_8_v1, b ore_64_8_v1) RETURNS boolean AS $$
  SELECT compare_ore_64_8_v1(a, b) != 1
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION ore_64_8_v1_gt(a ore_64_8_v1, b ore_64_8_v1) RETURNS boolean AS $$
  SELECT compare_ore_64_8_v1(a, b) = 1
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION ore_64_8_v1_gte(a ore_64_8_v1, b ore_64_8_v1) RETURNS boolean AS $$
  SELECT compare_ore_64_8_v1(a, b) != -1
$$ LANGUAGE SQL;

CREATE OPERATOR = (
  PROCEDURE="ore_64_8_v1_eq",
  LEFTARG=ore_64_8_v1,
  RIGHTARG=ore_64_8_v1,
  NEGATOR = <>,
  RESTRICT = eqsel,
  JOIN = eqjoinsel,
  HASHES,
  MERGES
);

CREATE OPERATOR <> (
  PROCEDURE="ore_64_8_v1_neq",
  LEFTARG=ore_64_8_v1,
  RIGHTARG=ore_64_8_v1,
  NEGATOR = =,
  RESTRICT = eqsel,
  JOIN = eqjoinsel,
  HASHES,
  MERGES
);

CREATE OPERATOR > (
  PROCEDURE="ore_64_8_v1_gt",
  LEFTARG=ore_64_8_v1,
  RIGHTARG=ore_64_8_v1,
  COMMUTATOR = <,
  NEGATOR = <=,
  RESTRICT = scalargtsel,
  JOIN = scalargtjoinsel
);

CREATE OPERATOR < (
  PROCEDURE="ore_64_8_v1_lt",
  LEFTARG=ore_64_8_v1,
  RIGHTARG=ore_64_8_v1,
  COMMUTATOR = >,
  NEGATOR = >=,
  RESTRICT = scalarltsel,
  JOIN = scalarltjoinsel
);

CREATE OPERATOR <= (
  PROCEDURE="ore_64_8_v1_lte",
  LEFTARG=ore_64_8_v1,
  RIGHTARG=ore_64_8_v1,
  COMMUTATOR = >=,
  NEGATOR = >,
  RESTRICT = scalarlesel,
  JOIN = scalarlejoinsel
);

CREATE OPERATOR >= (
  PROCEDURE="ore_64_8_v1_gte",
  LEFTARG=ore_64_8_v1,
  RIGHTARG=ore_64_8_v1,
  COMMUTATOR = <=,
  NEGATOR = <,
  RESTRICT = scalarlesel,
  JOIN = scalarlejoinsel
);

CREATE OPERATOR FAMILY ore_64_8_v1_btree_ops USING btree;
CREATE OPERATOR CLASS ore_64_8_v1_btree_ops DEFAULT FOR TYPE ore_64_8_v1 USING btree FAMILY ore_64_8_v1_btree_ops  AS
        OPERATOR 1 <,
        OPERATOR 2 <=,
        OPERATOR 3 =,
        OPERATOR 4 >=,
        OPERATOR 5 >,
        FUNCTION 1 compare_ore_64_8_v1(a ore_64_8_v1, b ore_64_8_v1);
