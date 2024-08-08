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

 --Ex3 Scenario 1: Process Monthly Interest for All Savings Accounts
 
CREATE OR REPLACE PROCEDURE ProcessMonthlyInterest IS
  CURSOR savings_accounts_cursor IS
    SELECT AccountID, CustomerID, Balance
    FROM Accounts
    WHERE AccountType = 'Savings'
      AND (SYSDATE - LastModified) >= 30
      FOR UPDATE;
  
  current_account_id Accounts.AccountID%TYPE;
  current_customer_id Accounts.CustomerID%TYPE;
  current_balance Accounts.Balance%TYPE;
BEGIN
  OPEN savings_accounts_cursor;
  
  LOOP
    FETCH savings_accounts_cursor INTO current_account_id, current_customer_id, current_balance;
    EXIT WHEN savings_accounts_cursor%NOTFOUND;
    
    UPDATE Accounts
    SET Balance = current_balance * 1.01,
        LastModified = SYSDATE
    WHERE AccountID = current_account_id;
    
    DBMS_OUTPUT.PUT_LINE('CurrentAccountID: ' || current_account_id || 
                         ', CurrentCustomerID: ' || current_customer_id || 
                         ', New Balance of the customer: ' || current_balance * 1.01);
  END LOOP;
  
  CLOSE savings_accounts_cursor;
  
  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('Monthly interest of 1% applied to all eligible savings accounts.');
END;
/
BEGIN
  ProcessMonthlyInterest;
END;
/

--Ex3 Scenario 2: Update Employee Bonus Based on Performance

CREATE OR REPLACE PROCEDURE UpdateEmployeeBonus(
  p_Department IN Employees.Department%TYPE,
  p_BonusPercentage IN NUMBER
)
IS
  v_RowCount NUMBER;
BEGIN
  -- Update the salary of employees in the specified department
  UPDATE Employees
  SET Salary = Salary + (Salary * p_BonusPercentage / 100)
  WHERE Department = p_Department;

  -- Get the number of rows affected
  v_RowCount := SQL%ROWCOUNT;

  -- Commit the changes
  COMMIT;

  -- Output the result
  DBMS_OUTPUT.PUT_LINE('Bonus of ' || p_BonusPercentage || '% applied to ' || v_RowCount || ' employees in department: ' || p_Department);
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;  -- Rollback in case of an error
    DBMS_OUTPUT.PUT_LINE('Error updating bonuses: ' || SQLERRM);
END;
/
BEGIN
  UpdateEmployeeBonus(p_Department => 'HR', p_BonusPercentage => 10);
END;
/
--Ex3 Scenario3: Transfer Funds Between Accounts

CREATE OR REPLACE PROCEDURE TransferFunds(
  p_FromAccountID IN Accounts.AccountID%TYPE,
  p_ToAccountID IN Accounts.AccountID%TYPE,
  p_Amount IN NUMBER
)
IS
  v_FromBalance Accounts.Balance%TYPE;
  v_ToBalance Accounts.Balance%TYPE;
BEGIN
  -- Check the balance of the source account
  SELECT Balance INTO v_FromBalance
  FROM Accounts
  WHERE AccountID = p_FromAccountID;

  -- Check if the source account has sufficient funds
  IF v_FromBalance < p_Amount THEN
    RAISE_APPLICATION_ERROR(-20001, 'Insufficient funds in the source account.');
  END IF;

  -- Deduct the amount from the source account
  UPDATE Accounts
  SET Balance = Balance - p_Amount
  WHERE AccountID = p_FromAccountID;

  -- Add the amount to the destination account
  SELECT Balance INTO v_ToBalance
  FROM Accounts
  WHERE AccountID = p_ToAccountID;

  UPDATE Accounts
  SET Balance = Balance + p_Amount
  WHERE AccountID = p_ToAccountID;

  -- Commit the changes
  COMMIT;

  -- Output the result
  DBMS_OUTPUT.PUT_LINE('Successfully transferred ' || p_Amount || ' from Account ID ' || p_FromAccountID || ' to Account ID ' || p_ToAccountID);
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;  -- Rollback in case of an error
    DBMS_OUTPUT.PUT_LINE('Error during fund transfer: ' || SQLERRM);
END;
/
BEGIN
  TransferFunds(p_FromAccountID => 1, p_ToAccountID => 2, p_Amount => 500);
END;
/