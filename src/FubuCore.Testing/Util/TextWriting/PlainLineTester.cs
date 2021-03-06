using System;
using System.IO;
using FubuCore.Util.TextWriting;
using Moq;
using NUnit.Framework;

namespace FubuCore.Testing.Util.TextWriting
{
    [TestFixture]
    public class PlainLineTester
    {
        [Test]
        public void width_is_the_text_width()
        {
            var text = "a bunch of text";
            var line = new PlainLine(text);

            line.Width.ShouldEqual(text.Length);
        }

        [Test]
        public void write()
        {
            var text = "a bunch of text";
            var line = new PlainLine(text);

            var writer = new Mock<TextWriter>();

            line.Write(writer.Object);

            writer.Verify(x => x.WriteLine(text));
        }

        [Test]
        public void write_to_console()
        {
            var writer = new Mock<TextWriter>();
            Console.SetOut(writer.Object);

            var text = "a bunch of text";
            var line = new PlainLine(text);

            line.Write(writer.Object);

            writer.Verify(x => x.WriteLine(text));
        }
    }
}