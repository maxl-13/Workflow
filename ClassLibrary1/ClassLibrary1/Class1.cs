using System.Reflection;
using System;
using System.Diagnostics;
using System.IO;

namespace ClassLibrary1
{
    public class Class1
    {
        public int sum (int x, int y)
        {
            if (x == y)
            {
                return 42;
            }

            else
            {
                return x + y;
            }
        }

        public static double Add(double x, double y)
        {
            return x + y;
        }
        public static double Multiply(double x, double y)
        {
            return x * y;
        }
        public static double Substract(double x, double y)
        {
            return x - y;
        }
        public static double Divide(double x, double y)
        {
            if (y != 0)
            {
                return x / y;
            }
            else
            {
                return 0;
            }
        }

        public static string TestException(string file)
        {
            if (file.Length < 10)
            {
                throw new System.IO.FileNotFoundException();
            }

            return "File loaded";
        }
        //

        static void Main(string[] args)
        {
            var assembly = Assembly.GetExecutingAssembly();
            var assemblyVersion = assembly.GetName().Version;
            Console.WriteLine($"AssemblyVersion {assemblyVersion}");

            var fileVersionInfo = FileVersionInfo.GetVersionInfo(assembly.Location);
            var fileVersion = fileVersionInfo.FileVersion;
            Console.WriteLine($"FileVersion {fileVersion}");

            var informationVersion = assembly.GetCustomAttribute<AssemblyInformationalVersionAttribute>().InformationalVersion;
            Console.WriteLine($"InformationalVersion  {informationVersion}");
            
            string folder = @".\..\..\..\..\..\";
            // Filename  
            string fileName = "version.txt";
            // Fullpath. You can direct hardcode it if you like.  
            string fullPath = folder + fileName;

            using (StreamWriter writer = new StreamWriter(fullPath))  
            {   
                writer.WriteLine($"InformationalVersion  {informationVersion}");  
            }  
                // Read a file  
                string readText = File.ReadAllText(fullPath);  
                Console.WriteLine(readText);  
        }
    }


}

