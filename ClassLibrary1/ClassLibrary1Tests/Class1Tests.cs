using Microsoft.VisualStudio.TestTools.UnitTesting;
using ClassLibrary1;
using System;
using System.Collections.Generic;
using System.Text;

namespace ClassLibrary1.Tests
{
    [TestClass()]
    public class Class1Tests
    {
        [TestMethod()]
        public void sumTest()
        {
            Class1 myTestClass = new Class1();
            if(42 != myTestClass.sum(21, 21))
            {
                Assert.Fail();
            }            
        }

        [TestMethod()]
        public void sumSpecialTest()
        {
            Class1 myTestClass = new Class1();
            if (42 != myTestClass.sum(42, 42))
            {
                Assert.Fail();
            }
        }

    }
}