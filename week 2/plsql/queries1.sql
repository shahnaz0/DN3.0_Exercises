--Tablestructure
BEGIN
  -- Create Customers Table
  EXECUTE IMMEDIATE 'CREATE TABLE Customers (
    CustomerID NUMBER PRIMARY KEY,
    Name VARCHAR2(100),
    DOB DATE,
    Balance NUMBER,
    LastModified DATE
  )';

  -- Create Accounts Table
  EXECUTE IMMEDIATE 'CREATE TABLE Accounts (
    AccountID NUMBER PRIMARY KEY,
    CustomerID NUMBER,
    AccountType VARCHAR2(20),
    Balance NUMBER,
    LastModified DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
  )';

  -- Create Transactions Table
  EXECUTE IMMEDIATE 'CREATE TABLE Transactions (
    TransactionID NUMBER PRIMARY KEY,
    AccountID NUMBER,
    TransactionDate DATE,
    Amount NUMBER,
    TransactionType VARCHAR2(10),
    FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
  )';

  -- Create Loans Table
  EXECUTE IMMEDIATE 'CREATE TABLE Loans (
    LoanID NUMBER PRIMARY KEY,
    CustomerID NUMBER,
    LoanAmount NUMBER,
    InterestRate NUMBER,
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
  )';

  -- Create Employees Table
  EXECUTE IMMEDIATE 'CREATE TABLE Employees (
    EmployeeID NUMBER PRIMARY KEY,
    Name VARCHAR2(100),
    Position VARCHAR2(50),
    Salary NUMBER,
    Department VARCHAR2(50),
    HireDate DATE
  )';
END;
/
BEGIN
  -- Insert into Customers
  INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
  VALUES (1, 'John Doe', TO_DATE('1950-05-15', 'YYYY-MM-DD'), 1000, SYSDATE);

  INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
  VALUES (2, 'Jane Smith', TO_DATE('1947-07-20', 'YYYY-MM-DD'), 1500, SYSDATE);

  -- Insert into Accounts
  INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, LastModified)
  VALUES (1, 1, 'Savings', 1000, SYSDATE);

  INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, LastModified)
  VALUES (2, 2, 'Checking', 1500, SYSDATE);

  -- Insert into Transactions
  INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
  VALUES (1, 1, SYSDATE, 200, 'Deposit');

  INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
  VALUES (2, 2, SYSDATE, 300, 'Withdrawal');

  -- Insert into Loans
  INSERT INTO Loans (LoanID, CustomerID, LoanAmount, InterestRate, StartDate, EndDate)
  VALUES (1, 1, 5000, 5, SYSDATE, ADD_MONTHS(SYSDATE, 60));
  INSERT INTO Loans (LoanID, CustomerID, LoanAmount, InterestRate, StartDate, EndDate)
  VALUES (2, 2, 5000, 10, SYSDATE, ADD_MONTHS(SYSDATE, 60));

  -- Insert into Employees
  INSERT INTO Employees (EmployeeID, Name, Position, Salary, Department, HireDate)
  VALUES (1, 'Alice Johnson', 'Manager', 70000, 'HR', TO_DATE('1900-07-20', 'YYYY-MM-DD'));

  INSERT INTO Employees (EmployeeID, Name, Position, Salary, Department, HireDate)
  VALUES (2, 'Bob Brown', 'Developer', 60000, 'IT', TO_DATE('2017-03-20', 'YYYY-MM-DD'));
END;
/

 --Ex1 Scenario:1

DECLARE
  CURSOR customer_cursor IS
    SELECT c.CustomerID, c.DOB, l.LoanID, l.InterestRate
    FROM Customers c
    JOIN Loans l ON c.CustomerID = l.CustomerID;

  v_age NUMBER;
BEGIN
  FOR customer_record IN customer_cursor LOOP
    v_age := TRUNC(MONTHS_BETWEEN(SYSDATE, customer_record.DOB) / 12);
    
    IF v_age > 60 THEN
      UPDATE Loans
      SET InterestRate = InterestRate - 1
      WHERE LoanID = customer_record.LoanID;
      DBMS_OUTPUT.PUT_LINE('Discount applied to LoanID ' || customer_record.LoanID || ' for CustomerID ' || customer_record.CustomerID);
    END IF;
  END LOOP;
  
  COMMIT;
END;
/
--Ex1 Scenario2
--Alter Customers Table
ALTER TABLE Customers ADD IsVIP CHAR(1) DEFAULT 'N';

-- PL/SQL Block to Update VIP Status
BEGIN
  UPDATE Customers
  SET IsVIP = 'Y'
  WHERE Balance > 10000;

  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' customers promoted to VIP status.');
  
  COMMIT;
END;
/

--Ex1 Scenario3

CREATE OR REPLACE PROCEDURE TransferFunds(
    src_acc_id IN Accounts.AccountID%TYPE,
    tgt_acc_id IN Accounts.AccountID%TYPE,
    amt IN NUMBER
) IS
    src_balance Accounts.Balance%TYPE;
BEGIN
    -- Retrieve the balance of the source account
    SELECT Balance
    INTO src_balance
    FROM Accounts
    WHERE AccountID = src_acc_id
    FOR UPDATE;

    -- Check if the source account has sufficient balance
    IF src_balance < amt THEN
        RAISE_APPLICATION_ERROR(-20001, 'Insufficient balance in source account.');
    END IF;

    -- Deduct the amount from the source account
    UPDATE Accounts
    SET Balance = Balance - amt
    WHERE AccountID = src_acc_id;

    -- Add the amount to the target account
    UPDATE Accounts
    SET Balance = Balance + amt
    WHERE AccountID = tgt_acc_id;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Funds transferred successfully: ' ||
                         'From AccountID ' || src_acc_id || 
                         ' To AccountID ' || tgt_acc_id ||
                         ' Amount ' || amt);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('One or both account IDs do not exist.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
BEGIN
  TransferFunds(src_acc_id => 2, 
                tgt_acc_id => 3, 
                amt => 100);
END;
/




