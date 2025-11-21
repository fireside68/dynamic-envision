import React, { useState } from 'react';
import { ChevronDown, MapPin, Phone, Mail, Star, Check } from 'lucide-react';
import fullLogo from './assets/fulllogo.png';
import transparentLogo from './assets/grayscale_transparent.png';

export default function DynamicEnvision() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    message: ''
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log('Form submitted:', formData);
    alert("Thanks for reaching out! We'll be in touch soon.");
    setFormData({ name: '', email: '', phone: '', message: '' });
  };

  return (
    <div className="w-full bg-amber-50">
      {/* Navigation */}
      <nav className="sticky top-0 z-50 bg-white/95 backdrop-blur shadow-sm">
        <div className="max-w-6xl mx-auto px-6 py-4 flex justify-between items-center">
          <div className="flex items-center gap-3">
            <img src={fullLogo} alt="Dynamic Envision Solutions" className="h-10 w-auto" />
            <span className="text-lg font-bold text-amber-900">Dynamic Envision</span>
          </div>
          <div className="flex gap-8 text-sm font-medium">
            <a href="#portfolio" className="text-amber-900 hover:text-amber-700 transition">Portfolio</a>
            <a href="#about" className="text-amber-900 hover:text-amber-700 transition">About</a>
            <a href="#reviews" className="text-amber-900 hover:text-amber-700 transition">Reviews</a>
            <a href="#contact" className="text-amber-900 hover:text-amber-700 transition">Contact</a>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="relative h-screen bg-gradient-to-b from-amber-100 via-orange-50 to-amber-50 overflow-hidden">
        <div className="absolute inset-0 opacity-20">
          <div className="absolute top-20 right-20 w-72 h-72 bg-orange-300 rounded-full mix-blend-multiply filter blur-3xl"></div>
          <div className="absolute -bottom-8 left-20 w-72 h-72 bg-amber-400 rounded-full mix-blend-multiply filter blur-3xl"></div>
        </div>

        <div className="relative h-full flex flex-col items-center justify-center px-6 text-center">
          <div className="mb-8 opacity-90">
            <div className="w-32 h-32 mx-auto mb-6 bg-white rounded-full p-4 shadow-lg flex items-center justify-center">
              <div className="relative"><img src={transparentLogo} alt="Dynamic Envision Solutions" /></div>
            </div>
          </div>

          <h1 className="text-6xl font-bold text-amber-950 mb-4 leading-tight">
            Premium Windows & Doors
          </h1>
          <p className="text-xl text-amber-800 mb-8 max-w-2xl">
            15 years of craftsmanship in the Denver metro area. We don't just replace windows—we transform your home's comfort and aesthetic.
          </p>

          <div className="flex gap-4 mb-12">
            <button className="bg-amber-900 text-white px-8 py-3 rounded-lg font-semibold hover:bg-amber-800 transition shadow-lg">
              Get a Quote
            </button>
            <button className="border-2 border-amber-900 text-amber-900 px-8 py-3 rounded-lg font-semibold hover:bg-amber-50 transition">
              View Our Work
            </button>
          </div>

          <div className="flex gap-12 text-amber-900 text-sm font-semibold mt-8">
            <div className="flex items-center gap-2">
              <MapPin className="w-5 h-5" />
              <span>Denver to Pueblo</span>
            </div>
            <div className="flex items-center gap-2">
              <Phone className="w-5 h-5" />
              <span>Free Consultations</span>
            </div>
          </div>

          <div className="absolute bottom-8 animate-bounce">
            <ChevronDown className="w-6 h-6 text-amber-800" />
          </div>
        </div>
      </section>

      {/* Portfolio Section */}
      <section id="portfolio" className="py-20 px-6 bg-white">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-amber-950 mb-4">Our Work</h2>
            <p className="text-lg text-amber-700">Every project tells a story of quality and attention to detail</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[1, 2, 3, 4, 5, 6].map((item) => (
              <div key={item} className="group relative overflow-hidden rounded-lg shadow-lg hover:shadow-xl transition h-64 bg-gradient-to-br from-amber-200 to-orange-200 flex items-center justify-center cursor-pointer">
                <div className="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition"></div>
                <div className="text-center z-10">
                  <p className="text-amber-900 font-semibold mb-2">Project {item}</p>
                  <p className="text-sm text-amber-800">[Photo placeholder]</p>
                </div>
              </div>
            ))}
          </div>

          <div className="text-center mt-12">
            <p className="text-amber-700 italic mb-4">Ready to upload your project photos? Contact us to add more to your portfolio.</p>
          </div>
        </div>
      </section>

      {/* About Section */}
      <section id="about" className="py-20 px-6 bg-gradient-to-b from-amber-50 to-orange-50">
        <div className="max-w-4xl mx-auto">
          <div className="text-center mb-12">
            <h2 className="text-4xl font-bold text-amber-950 mb-4">Why Dynamic Envision?</h2>
          </div>

          <div className="grid md:grid-cols-2 gap-12">
            <div>
              <h3 className="text-2xl font-bold text-amber-900 mb-6">Our Story</h3>
              <p className="text-amber-800 leading-relaxed mb-4">
                For 15 years, we've been helping homeowners and businesses in the Denver metro area transform their spaces with premium window and door solutions. What started as a passion for quality craftsmanship has grown into a trusted name from Cheyenne to Pueblo.
              </p>
              <p className="text-amber-800 leading-relaxed">
                We believe that great windows aren't just about aesthetics—they're about energy efficiency, security, and peace of mind. Every project we undertake reflects our commitment to excellence and customer satisfaction.
              </p>
            </div>

            <div>
              <h3 className="text-2xl font-bold text-amber-900 mb-6">What Sets Us Apart</h3>
              <div className="space-y-4">
                {[
                  'Expert installation with 15+ years experience',
                  'Premium quality materials and products',
                  'Detailed consultations and custom solutions',
                  'Competitive pricing and transparent quotes',
                  'Professional, respectful service',
                  'Warranty coverage and ongoing support'
                ].map((item, idx) => (
                  <div key={idx} className="flex gap-3 items-start">
                    <Check className="w-6 h-6 text-amber-700 flex-shrink-0 mt-0.5" />
                    <p className="text-amber-800">{item}</p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Reviews Section */}
      <section id="reviews" className="py-20 px-6 bg-white">
        <div className="max-w-4xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-amber-950 mb-4">What Our Customers Say</h2>
            <p className="text-lg text-amber-700">Reviews coming soon as we build our client portfolio</p>
          </div>

          <div className="bg-gradient-to-r from-amber-50 to-orange-50 rounded-lg p-12 text-center mb-12 border-2 border-dashed border-amber-300">
            <p className="text-amber-800 text-lg mb-4">
              We're currently building our review section. Early clients are always the foundation of trust.
            </p>
            <p className="text-amber-700 font-semibold">
              Have we worked with you? We'd love your feedback!
            </p>
          </div>

          <div className="text-center">
            <h3 className="text-xl font-semibold text-amber-900 mb-4">Find us on Google</h3>
            <p className="text-amber-700 mb-4">
              Check out our reviews and ratings on Google Maps for verified customer feedback
            </p>
            <a href="#" className="inline-block bg-amber-900 text-white px-6 py-2 rounded-lg font-semibold hover:bg-amber-800 transition">
              View on Google
            </a>
          </div>
        </div>
      </section>

      {/* Contact Section */}
      <section id="contact" className="py-20 px-6 bg-amber-900 text-white">
        <div className="max-w-2xl mx-auto">
          <div className="text-center mb-12">
            <h2 className="text-4xl font-bold mb-4">Get Your Free Quote</h2>
            <p className="text-amber-100">Let's discuss your window and door needs</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-6 mb-12">
            <div>
              <label className="block text-sm font-semibold mb-2">Name</label>
              <input
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="w-full px-4 py-3 rounded-lg bg-white text-amber-950 focus:outline-none focus:ring-2 focus:ring-amber-300"
                required
              />
            </div>

            <div className="grid md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-semibold mb-2">Email</label>
                <input
                  type="email"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  className="w-full px-4 py-3 rounded-lg bg-white text-amber-950 focus:outline-none focus:ring-2 focus:ring-amber-300"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-semibold mb-2">Phone</label>
                <input
                  type="tel"
                  value={formData.phone}
                  onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                  className="w-full px-4 py-3 rounded-lg bg-white text-amber-950 focus:outline-none focus:ring-2 focus:ring-amber-300"
                  required
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-semibold mb-2">Tell us about your project</label>
              <textarea
                value={formData.message}
                onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                rows="5"
                className="w-full px-4 py-3 rounded-lg bg-white text-amber-950 focus:outline-none focus:ring-2 focus:ring-amber-300"
                required
              ></textarea>
            </div>

            <button
              type="submit"
              className="w-full bg-white text-amber-900 py-3 rounded-lg font-bold text-lg hover:bg-amber-50 transition shadow-lg"
            >
              Request a Quote
            </button>
          </form>

          <div className="border-t border-amber-800 pt-12 grid md:grid-cols-3 gap-8 text-center">
            <div>
              <div className="text-2xl mb-2">📞</div>
              <p className="text-sm text-amber-100">Call for immediate assistance</p>
            </div>
            <div>
              <div className="text-2xl mb-2">📍</div>
              <p className="text-sm text-amber-100">Denver Metro Area to Pueblo</p>
            </div>
            <div>
              <div className="text-2xl mb-2">✓</div>
              <p className="text-sm text-amber-100">Free consultations available</p>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-amber-950 text-amber-100 py-8 px-6 text-center">
        <p className="text-sm">© 2024 Dynamic Envision Solutions. All rights reserved.</p>
      </footer>
    </div>
  );
}
