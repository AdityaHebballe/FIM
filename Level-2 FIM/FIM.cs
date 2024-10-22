namespace MyNamespace
{
    class MyClassCS
    {
        private static string? pathToMonitor;

        static void Main()
        {
            // Input validation
            while (true)
            {
                Console.WriteLine("Path of the folder to be monitored (Eg: C:\\Users\\guy\\Documents\\Files):");
                pathToMonitor = Console.ReadLine();

                if (!string.IsNullOrEmpty(pathToMonitor) && Directory.Exists(pathToMonitor))
                {
                    break;
                }
                else
                {
                    // Colored output to be fancyyyy
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine("Invalid path. Please enter a valid directory path.");
                    Console.ResetColor();
                }
            }

            using var watcher = new FileSystemWatcher(pathToMonitor);
            // NotifyFilter can check Attributes, CreationTime, DirectoryName, FileName, LastAccess, LastWrite, Size, Security.
            watcher.NotifyFilter = NotifyFilters.LastWrite
                     | NotifyFilters.FileName
                     | NotifyFilters.DirectoryName
                     | NotifyFilters.Attributes;

            watcher.Changed += OnChanged;
            watcher.Created += OnCreated;
            watcher.Deleted += OnDeleted;
            watcher.Renamed += OnRenamed;
            watcher.Error += OnError;

            // Change to any file type, for more than one file type event handler can be used.
            watcher.Filter = "*.txt";
            watcher.IncludeSubdirectories = true;
            watcher.EnableRaisingEvents = true;

            // Exit
            Console.WriteLine("Press enter to stop monitoring and exit.");
            Console.ReadLine();
        }

        // Logging function
        private static void LogEvent(string message)
        {

            string filename = "baseline.log"; // Replace with your desired filenamec
            string fullPath = Path.Combine(pathToMonitor, filename);
            if (!File.Exists(fullPath))
            {
                using (FileStream fs = File.Create(fullPath)) { }
            }
            // Set file limit in MB
            int fileSize = 5;
            if (File.Exists(fullPath) && new FileInfo(fullPath).Length > fileSize * (1024 * 1024)) // Check if the file is larger than fileSize
            {
                File.Move(fullPath, $"{fullPath}.{DateTime.Now:yyyyMMddHHmmss}"); // Rename the old log file
            }

            using (StreamWriter writer = new StreamWriter(fullPath, true))
            {
                writer.WriteLine($"{DateTime.Now}: {message}");
            }
        }

        // Functions for Altered, Created, Renamed, or Deleted. Add more if required.
        private static void OnChanged(object sender, FileSystemEventArgs e)
        {
            if (e.ChangeType != WatcherChangeTypes.Changed)
            {
                return;
            }
            string message = $"Changed: {e.FullPath}";
            LogEvent(message);
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine(message);
            Console.ResetColor();
        }

        private static void OnCreated(object sender, FileSystemEventArgs e)
        {
            string message = $"Created: {e.FullPath}";
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine(message);
            Console.ResetColor();
            LogEvent(message);
        }

        private static void OnDeleted(object sender, FileSystemEventArgs e)
        {
            string message = $"Deleted: {e.FullPath}";
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine(message);
            Console.ResetColor();
            LogEvent(message);
        }

        private static void OnRenamed(object sender, RenamedEventArgs e)
        {
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine($"Renamed:");
            Console.ResetColor();
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"    Old: {e.OldFullPath}");
            Console.ResetColor();
            Console.ForegroundColor = ConsoleColor.Blue;
            Console.WriteLine($"    New: {e.FullPath}");
            Console.ResetColor();
            string message = $"Renamed: Old: {e.OldFullPath}, New: {e.FullPath}";
            LogEvent(message);
        }

        private static void OnError(object sender, ErrorEventArgs e) =>
            PrintException(e.GetException());

        // Obligatory Error Handling
        private static void PrintException(Exception? ex)
        {
            if (ex != null)
            {
                Console.WriteLine($"Message: {ex.Message}");
                Console.WriteLine("Stacktrace:");
                Console.WriteLine(ex.StackTrace);
                Console.WriteLine();
                PrintException(ex.InnerException);
            }
        }
    }
}
