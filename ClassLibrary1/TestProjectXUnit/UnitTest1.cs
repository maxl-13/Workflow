using Xunit;
using ClassLibrary1;
using System.IO;

namespace TestProjectXUnit
{
    public class UnitTest1
    {
        [Theory]
        [InlineData(4, 3, 7)]
        [InlineData(21, 5.25, 26.25)]
        [InlineData(double.MaxValue, 5, double.MaxValue)]

        public void Add_SimpleValuesShouldCalculate(double x, double y, double expected)
        {
            // Act
            double actual = Class1.Add(x, y);

            // Assert
            Assert.Equal(expected, actual);

        }

        /*[Fact]
        public void Subtract_SimpleValuesShouldCalculate()
        {
            // Arrange
            double expected = 5;

            // Act
            double actual = Class1.Substract(5, 0);

            // Assert
            Assert.Equal(expected, actual);
        }

               [Fact]
        public void Multiply_SimpleValuesShouldCalculate()
        {
            // Arrange
            double expected = 6;

            // Act
            double actual = Class1.Multiply(3, 2);

            // Assert
            Assert.Equal(expected, actual);
        }

        [Theory]
        [InlineData(8, 4, 2)]
        public void Divide_SimpleValuesShouldCalculate(double x, double y, double expected)
        {
            double actual = Class1.Divide(x, y);

            Assert.Equal(expected, actual);
        }*/

        [Fact]
        public void Divide_ByZero()
        {
            double expected = 0;

            double actual = Class1.Divide(15, 0);

            Assert.Equal(expected, actual);
        }

        [Fact]
        public void ValidNameSchouldWork()
        {
            string actual = Class1.TestException("This is a placeholder file name");

            Assert.True(actual.Length > 0);
        }
        [Fact]
        public void InvalidNameSchouldFail()
        {
            Assert.Throws<FileNotFoundException>(() => Class1.TestException(""));
        }

    }
}