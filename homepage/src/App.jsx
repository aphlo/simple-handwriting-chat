import LanguageRedirect from './components/LanguageRedirect';
import Layout from './components/Layout';

function App() {
  return (
    <Routes>
      <Route path="/" element={<LanguageRedirect />} />
      <Route path="/:lang" element={<Layout />}>
        <Route index element={<Home />} />
        <Route path="terms" element={<Terms />} />
        <Route path="privacy" element={<Privacy />} />
      </Route>
    </Routes>
  );
}

export default App;
