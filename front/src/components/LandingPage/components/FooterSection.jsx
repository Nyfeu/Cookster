import './FooterSection.css'

const FooterSection = () => {
    return (
        <footer className="px-5 custom-footer">
            <div className="d-flex flex-column align-items-center text-center gap-2 flex-sm-row justify-content-between py-1 my-3">
                <p className="mb-0">&copy; 2025 Cookster, Inc. All rights reserved.</p>
                <ul className="list-unstyled d-flex gap-4 mb-0 mt-3 mt-sm-0">
                    <li className="ms-3"><a className="text-white" href="#"><i className="fab fa-facebook-f fa-lg"></i></a></li>
                    <li className="ms-3"><a className="text-white" href="#"><i className="fab fa-twitter fa-lg"></i></a></li>
                    <li className="ms-3"><a className="text-white" href="#"><i className="fab fa-google fa-lg"></i></a></li>
                    <li className="ms-3"><a className="text-white" href="#"><i className="fab fa-linkedin fa-lg"></i></a></li>
                </ul>
            </div>
        </footer>
    )
}

export default FooterSection